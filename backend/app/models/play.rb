# == Schema Information
#
# Table name: plays
#
#  id                     :bigint(8)        not null, primary key
#  away_score             :integer          default(0)
#  away_scorers           :jsonb
#  correct_scorers        :integer
#  correct_team_goals     :integer
#  goals_off              :integer
#  home_score             :integer          default(0)
#  home_scorers           :jsonb
#  payment_status         :integer          default("temp_accepted")
#  rank                   :integer
#  team_goals             :jsonb
#  winner_team            :integer          default("draw")
#  winner_team_is_correct :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  ledger_entry_id        :integer
#  match_id               :integer
#  user_id                :integer
#
# Indexes
#
#  index_plays_on_ledger_entry_id  (ledger_entry_id)
#  index_plays_on_match_id         (match_id)
#  index_plays_on_user_id          (user_id)
#

class Play < ApplicationRecord
  enum payment_status: {
    temp_accepted: 0, # Payed with unconfirmed credit
    accepted:      1, # Payed with confirmed credit, and match play stats applied
    late:          2, # did not confirm on time so scheduled to be declined
    declined:      3  # user has been notified and the unconfirmed funds returned to their wallet
  }

  enum winner_team: {
    draw: 0,
    home: 1,
    away: 2
  }
  
  belongs_to :user
  belongs_to :match
  belongs_to :ledger_entry
  has_many :notifs, as: :target # Win or Lose?

  validates_presence_of :payment_status
  validates_presence_of :match
  validates_presence_of :user
  validates_numericality_of :home_score, 
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to:    14,
                            on: :create

  validates_numericality_of :away_score, 
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to:    14,
                            on: :create

  validate :has_valid_scorers, on: :create
  validate :has_valid_team_goals, on: :create
  validate :has_valid_winner_team, on: :create
  validate :user_has_sufficient_funds, on: :create

  before_create :user_pays_for_ticket
  after_create  :try_accepting_payment!

  scope :accepted_ones, -> () { where(payment_status: :accepted) }
  scope :first_ranked,  -> () { where(payment_status: :accepted, rank: 1) }
  scope :losers,        -> () { where(payment_status: :accepted).where('rank > 1') }

  def has_valid_scorers
    if self.home_scorers.size != self.home_score
      errors.add(:home_scorers, 'count is invalid')
    end
    if self.away_scorers.size != self.away_score
      errors.add(:away_scorers, 'count is invalid')
    end
    
    self.home_scorers.each do |home_scorer|
      scorer_id   = home_scorer.fetch('id', nil)
      scorer_name = home_scorer.fetch('name', nil)
      found_name  = Player.where(id: scorer_id).pluck(:name).first
      if scorer_id.nil? || scorer_name.nil? || scorer_name != found_name
        errors.add(:home_scorers, 'includes invalid players')
      end
    end

    self.away_scorers.each do |away_scorer|
      scorer_id   = away_scorer.fetch('id', nil)
      scorer_name = away_scorer.fetch('name', nil)
      found_name  = Player.where(id: scorer_id).pluck(:name).first
      if scorer_id.nil? || scorer_name.nil? || scorer_name != found_name
        errors.add(:away_scorers, 'includes invalid players')
      end
    end
  end

  def has_valid_team_goals
    sum_of_goals_is_incorrect = self.home_score + self.away_score != self.team_goals.size
    home_goals_count_is_incorrect = self.team_goals.select { |goal_team| goal_team == 'home' }.size != self.home_score
    away_goals_count_is_incorrect = self.team_goals.select { |goal_team| goal_team == 'away' }.size != self.away_score
    if sum_of_goals_is_incorrect
      errors.add(:team_goals, 'count does not match with sum of home and away goals')
    end
    if home_goals_count_is_incorrect
      errors.add(:team_goals, 'includes wrong number of home goals')
    end
    if away_goals_count_is_incorrect
      errors.add(:team_goals, 'includes wrong number of away goals')
    end
  end

  def has_valid_winner_team
    home_wins  = self.winner_team == 'home' && self.home_score > self.away_score
    away_wins  = self.winner_team == 'away' && self.home_score < self.away_score
    its_a_draw = self.winner_team == 'draw' && self.home_score == self.away_score    
    if !home_wins && !away_wins && !its_a_draw
      errors.add(:winner_team, 'does not match with home and away goals')
    end
  end

  def user_has_sufficient_funds
    return if self.user.nil? || self.user == User.ai || self.match.nil?
    if self.user.wallet.total < self.match.ticket_fee
      errors.add(:user, 'has insufficient funds')
    end
  end

  def user_pays_for_ticket
    ledger_entry = self.user.wallet.pay_to!(
      dest_wallet: self.match.wallet, 
      amount: self.match.ticket_fee, 
      kind: :ticket_payment,
      add_as_locked: false, 
      accept_unconfirmed: true, 
      src_desc: "Ticket fee for #{self.match.friendly_event_name}",
      dest_desc: "Payment from User #{self.user.id}"
    )
    self.ledger_entry_id = ledger_entry.id
  end

  def try_accepting_payment!
    raise AppError::PlayAlreadyAccepted if self.accepted?
    raise AppError::CannotAcceptLatePlay if self.late?
    raise AppError::CannotAcceptDeclinedPlay if self.declined?

    if self.ledger_entry.unconfirmed == 0
      Db.atomically do
        self.update!(payment_status: :accepted)
        self.match.increment_pool_size!
        Notif.create!(
          kind: :play_accepted,
          user_id: self.user_id,
          data: {
            play_id: self.id,
            match_name: self.match.short_name
          }
        )
      end
    else
      self.update!(payment_status: :temp_accepted)
    end
  end

  def decline!
    raise AppError::CannotDeclineNonLatePlay if !self.late?
    raise AppError::CannotDeclinePlayWithConfirmedPayment if self.ledger_entry.confirmed == self.ledger_entry.total

    home_team, away_team = Match.where(id: self.match_id).pluck(:_home_team, :_away_team).last
    Db.atomically do
      self.update!(payment_status: :declined)
      self.ledger_entry.reverse!
      Notif.create!({
        user_id: self.user_id,
        kind: :play_declined,
        data: {
          play_id: self.id,
          match_name: "#{home_team['name']} vs #{away_team['name']}"
        }
      })
    end
  end

end
