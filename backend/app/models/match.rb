# == Schema Information
#
# Table name: matches
#
#  id                      :bigint(8)        not null, primary key
#  _away_team              :jsonb
#  _home_team              :jsonb
#  _league                 :jsonb
#  away_score              :integer          default(0)
#  check_started_scheduled :boolean          default(FALSE)
#  estimated_chance        :float            default(0.0)
#  estimated_prize         :float            default(0.0)
#  formation_synced        :boolean          default(FALSE)
#  goals                   :jsonb
#  highlights_synced       :boolean          default(FALSE)
#  home_score              :integer          default(0)
#  hotness_rank            :integer          default(10000)
#  pool_size               :integer          default(0)
#  pool_status             :integer          default("betting_closed")
#  prize_share             :float            default(0.0)
#  pushed_to_social_media  :boolean          default(FALSE)
#  real_chance             :float            default(0.0)
#  real_prize              :float            default(0.0)
#  stadium                 :string
#  starts_at               :datetime
#  status                  :integer          default("not_started")
#  ticket_fee              :float            default(0.0)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  away_team_id            :integer
#  home_team_id            :integer
#  league_id               :integer
#  prize_rule_id           :integer
#  season_id               :integer
#  sm_id                   :string
#
# Indexes
#
#  index_matches_on_away_team_id   (away_team_id)
#  index_matches_on_home_team_id   (home_team_id)
#  index_matches_on_league_id      (league_id)
#  index_matches_on_prize_rule_id  (prize_rule_id)
#  index_matches_on_season_id      (season_id)
#

class Match < ApplicationRecord
  enum status: {
    not_started: 0,
    in_progress: 1,
    finished:    2,
    unknown:     3
  }
  enum pool_status: {
    betting_closed:  0, # We have not started accepting bets
    betting_open:    1, # People can place bet
    pending_outcome: 2, # Waiting for the outcome of the match to determine the winner
    finalized:       3  # Game is finished and winners have received their prize
  }

  belongs_to :league
  belongs_to :season
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  belongs_to :prize_rule

  has_one    :wallet, as: :owner
  has_many   :plays
  has_many   :highlights

  scope :upcoming, -> { 
    where(pool_status: :betting_open)
    .where('starts_at < ?', 2.weeks.from_now.utc.end_of_week)
    .where('starts_at > ?', DateTime.now)
  }

  before_create :set_cached_attrs
  after_create :create_wallet
  
  def set_cached_attrs
    self._league          = LeagueSerializer.serialize(self.league)
    self._home_team       = TeamSerializer.serialize(self.home_team)
    self._away_team       = TeamSerializer.serialize(self.away_team)
    self.hotness_rank     = self.home_team.rank + self.away_team.rank
    self.estimated_prize  = self.estimate_prize
    self.estimated_chance = self.estimate_chance
    self.real_chance      = self.calc_real_chance
    self.real_prize       = self.calc_real_prize
  end

  def create_wallet
    Wallet.create owner: self
  end

  def calc_real_chance
    chance = self.pool_size != 0 ? 100.0 / self.pool_size : 0
    return 0 if chance == 0
    round_by = chance > 1 ? 0 : Math.log(chance, 10).abs.ceil
    chance.round(round_by)
  end

  def calc_real_prize
    self.prize_rule.calculate_prize(self.pool_size, self.ticket_fee)
  end

  def estimate_chance
    chance   = self.pool_size == 0 ? 50 : 100.0 / (1 + self.pool_size)
    round_by = chance > 1 ? 0 : Math.log(chance, 10).abs.ceil
    chance.round(round_by)
  end

  def estimate_prize
    bettors = self.pool_size < 2 ? 2 : self.pool_size + 1
    self.prize_rule.calculate_prize(bettors, self.ticket_fee)
  end

  def friendly_event_name
    "#{self._home_team['name']} vs #{self._away_team['name']} on #{self.starts_at.to_date.to_s}"
  end

  def short_name
    "#{self._home_team['name']} vs #{self._away_team['name']}"
  end

  def increment_pool_size!
    Db.atomically do
      self.pool_size += 1
      self.estimated_prize  = self.estimate_prize
      self.estimated_chance = self.estimate_chance
      self.real_chance      = self.calc_real_chance
      self.real_prize       = self.calc_real_prize
      self.save!
      if self.pool_size == 1
        self.place_play_of_ai!
      end
    end
  end

  def place_play_of_ai!
    ai = User.ai
    ai_play = Play.find_hash_by(user_id: ai.id, match_id: self.id)
    raise AppError::AiAlreadyPlayed if !ai_play.nil?
    
    winner_team = self._home_team['rank'] > self._away_team['rank'] ? 'home' : 'away'
    team_scores = [[1, 0], [2, 0], [2, 1], [3, 0], [3, 1]].sample
    home_score  = winner_team == 'home' ? team_scores.first : team_scores.last
    away_score  = winner_team == 'away' ? team_scores.first : team_scores.last
    team_goals  = Array.new(home_score, 'home') + Array.new(away_score, 'away')
    
    home_scorers = Player
      .where(team_id: self.home_team_id)
      .order(goals_per_min: :desc)
      .limit(home_score)
      .pluck(:id, :name)
      .map { |record| {id: record[0], name: record[1]} }

    away_scorers = Player
      .where(team_id: self.away_team_id)
      .order(goals_per_min: :desc)
      .limit(away_score)
      .pluck(:id, :name)
      .map { |record| {id: record[0], name: record[1]} }

    Play.create!(
      winner_team:  winner_team,
      home_score:   home_score,
      away_score:   away_score,
      home_scorers: home_scorers,
      away_scorers: away_scorers,
      team_goals:   team_goals,
      user:         ai,
      match_id:     self.id
    )
  end

  def start!
    has_an_expected_status = self.in_progress? || self.finished?
    raise AppError::MatchMustBeInProgressOrFinished if !has_an_expected_status
    raise AppError::MatchAlreadyStarted if self.pending_outcome?

    target_user_ids = self.plays.where(payment_status: :temp_accepted).pluck(:user_id)
    
    tobe_checked_txids = Transfer
      .joins(ledger_entries: :wallet)
      .where(wallets: { owner_type: 'User', owner_id: target_user_ids })
      .where('ledger_entries.total > 0 AND ledger_entries.total != ledger_entries.confirmed')
      .pluck(:txid)

    tobe_checked_txids.each { |txid| Bitcoin.check_transaction(txid) }
    
    tobe_declined_play_ids = self.plays.where(payment_status: :temp_accepted).pluck(:id)
    tobe_notified_play_ids = self.plays.where(payment_status: :accepted).pluck(:id)
    Db.atomically do
      self.update!(pool_status: :pending_outcome)
      self.plays.where(payment_status: :temp_accepted).update_all(payment_status: :late)
      tobe_declined_play_ids.each { |play_id| DeclinePlayWorker.perform_async(play_id) }
      tobe_notified_play_ids.each { |play_id| NotifyMatchStartedWorker.perform_async(play_id) }
      CheckMatchFinishedWorker.perform_at(self.starts_at + 105.minutes, self.id)
    end
  end

  def winner_team
    if self.home_score > self.away_score
      return 'home'
    elsif self.home_score < self.away_score
      return 'away'
    else
      return 'draw'
    end
  end

  def rank_plays!
    raise AppError::MatchMustBeFinished if !self.finished?
    raise AppError::MatchAlreadyFinalized if self.finalized?
    
    plays_indexed = self.plays.accepted_ones.indexed_serialize(PlaySerializer)
    return if plays_indexed.empty?

    Db.atomically do
      ranking_array = []
      
      step = 1
      actual_winner_team = self.winner_team
      correct_winner_team_play_ids   = []
      incorrect_winner_team_play_ids = []
      plays_indexed.values.each do |play|
        if play[:winner_team] == actual_winner_team
          correct_winner_team_play_ids << play[:id]
        else
          incorrect_winner_team_play_ids << play[:id]
        end
      end
      Play.where(id: correct_winner_team_play_ids).update_all(winner_team_is_correct: true)
      Play.where(id: incorrect_winner_team_play_ids).update_all(winner_team_is_correct: false)
      ranking_array << incorrect_winner_team_play_ids
      if correct_winner_team_play_ids.size == 1
        ranking_array << correct_winner_team_play_ids
        done_yet = true
      end
      incorrect_winner_team_play_ids.each { |play_id| plays_indexed.delete(play_id) }
      
      if !done_yet
        step = 2
        map_goals_off_to_play_id = {}
        plays_indexed.values.each do |play|
          goals_off = (play[:home_score] - self.home_score).abs + (play[:away_score] - self.away_score).abs
          if map_goals_off_to_play_id.has_key?(goals_off)
            map_goals_off_to_play_id[goals_off][:play_ids] << play[:id]
          else
            map_goals_off_to_play_id[goals_off] = { goals_off: goals_off, play_ids: [ play[:id] ] }
          end
        end
        goals_off_groups_sorted = map_goals_off_to_play_id.values.sort_by { |item| item[:goals_off] }.reverse
        goals_off_groups_sorted.each.with_index do |goals_off_group, index|
          Play.where(id: goals_off_group[:play_ids]).update_all(goals_off: goals_off_group[:goals_off])
          if index < goals_off_groups_sorted.size - 1
            ranking_array << goals_off_group[:play_ids]
            goals_off_group[:play_ids].each { |play_id| plays_indexed.delete(play_id) }
          elsif goals_off_group[:play_ids].size == 1
            ranking_array << goals_off_group[:play_ids]
            done_yet = true
          end
        end
      end

      if !done_yet
        step = 3
        map_correct_scorers_to_play_id = {}
        match_scorer_ids = self.find_scorer_ids
        plays_indexed.values.each do |play|
          play_scorer_ids = (play[:home_scorers] + play[:away_scorers]).pluck('id')
          correct_scorers = self.count_correct_scorers(match_scorer_ids, play_scorer_ids)
          if map_correct_scorers_to_play_id.has_key?(correct_scorers)
            map_correct_scorers_to_play_id[correct_scorers][:play_ids] << play[:id]
          else
            map_correct_scorers_to_play_id[correct_scorers] = { correct_scorers: correct_scorers, play_ids: [ play[:id] ] }
          end
        end
        correct_scorers_groups_sorted = map_correct_scorers_to_play_id.values.sort_by { |item| item[:correct_scorers] }
        correct_scorers_groups_sorted.each.with_index do |correct_scorers_group, index|
          Play.where(id: correct_scorers_group[:play_ids]).update_all(correct_scorers: correct_scorers_group[:correct_scorers])
          if index < correct_scorers_groups_sorted.size - 1
            ranking_array << correct_scorers_group[:play_ids]
            correct_scorers_group[:play_ids].each { |play_id| plays_indexed.delete(play_id) }
          elsif correct_scorers_group[:play_ids].size == 1
            ranking_array << correct_scorers_group[:play_ids]
            done_yet = true
          end
        end
      end
  
      if !done_yet
        step = 4
        map_correct_team_goals_to_play_id = {}
        match_team_gaols = self.goals
          .sort_by { |goal| [goal['minute'].to_i, goal['extra_minute'].to_i] }
          .map     { |goal| goal['team'] }
        plays_indexed.values.each do |play|
          correct_team_goals = self.count_correct_team_goals(match_team_gaols, play[:team_goals])
          if map_correct_team_goals_to_play_id.has_key?(correct_team_goals)
            map_correct_team_goals_to_play_id[correct_team_goals][:play_ids] << play[:id]
          else
            map_correct_team_goals_to_play_id[correct_team_goals] = { correct_team_goals: correct_team_goals, play_ids: [ play[:id] ] }
          end
        end
        correct_team_goals_groups_sorted = map_correct_team_goals_to_play_id.values.sort_by { |item| item[:correct_team_goals] }
        correct_team_goals_groups_sorted.each do |correct_team_goals_group|
          Play.where(id: correct_team_goals_group[:play_ids]).update_all(correct_team_goals: correct_team_goals_group[:correct_team_goals])
          ranking_array << correct_team_goals_group[:play_ids]
        end
      end
      
      ranking_array.reverse.each.with_index do |ranking_group, index|
        Play.where(id: ranking_group).update_all(rank: index + 1)
      end
    end
  end

  def deliver_prizes!
    winner_plays = self.plays.first_ranked.pluck(:id, :user_id)
    return if winner_plays.empty?
    
    each_prize   = Calc.div(self.real_prize, winner_plays.size).round(4)
    total_prize  = Calc.mult(each_prize, winner_plays.size)
    profit       = Calc.sub(self.wallet.confirmed, total_prize)
    
    Db.atomically do
      winner_plays.each do |winner_play|
        winner_wallet = Wallet.find_by(owner_type: 'User', owner_id: winner_play.second)
        self.wallet.pay_to!(
          dest_wallet: winner_wallet,
          kind: :prize_transfer,
          amount: each_prize, 
          add_as_locked: false, 
          accept_unconfirmed: false, 
          src_desc: "Prize payment to play #{winner_play.first}",
          dest_desc: "Prize for your bet on #{self.friendly_event_name}"
        )
      end
      
      if profit != 0
        self.wallet.pay_to!(
          dest_wallet: Wallet.master,
          kind: :revenue_transfer,
          amount: profit, 
          add_as_locked: false, 
          accept_unconfirmed: false, 
          src_desc: "Revenue payed to master wallet",
          dest_desc: "Revenue from match #{self.id}"
        )
      end

      self.update!(prize_share: each_prize)
    end
  end

  def make_final_notifs!
    winner_plays = self.plays.joins(:user).first_ranked.pluck(:id, :user_id, 'users.username')
    return if winner_plays.empty?
    
    winner_plays.each do |winner_play|
      Notif.create!({
        user_id: winner_play.second,
        kind: :pool_won,
        data: {
          play_id:     winner_play.first,
          match_name:  self.short_name,
          prize_share: self.prize_share
        }
      })
    end

    winner_usernames = winner_plays.map(&:last)
    loser_plays      = self.plays.losers.pluck(:id, :user_id, :rank)
    loser_plays.each do |loser_play|
      Notif.create!(
        user_id: loser_play.second,
        kind: :pool_lost,
        data: {
          play_id:    loser_play.first,
          match_name: self.short_name,
          play_rank:  loser_play.third
        }
      )
    end
  end

  def finalize!
    raise AppError::MatchMustBeFinished if !self.finished?
    raise AppError::MatchAlreadyFinalized if self.finalized?

    Db.atomically do
      self.rank_plays!
      self.deliver_prizes!
      self.make_final_notifs!
      self.update!(pool_status: :finalized)
    end
  end

  def find_scorer_ids
    scorer_sm_ids = self.goals.map { |item| item['player_sm_id'] }
    map_sm_id_to_id = {}
    Player.where(sm_id: scorer_sm_ids).pluck(:sm_id, :id).each do |pair|
      map_sm_id_to_id[pair.first] = pair.last
    end

    return scorer_sm_ids.map { |sm_id| map_sm_id_to_id[sm_id] }
  end

  def count_correct_scorers(match_scorer_ids, play_scorer_ids)
    match_scorers_map = {}
    match_scorer_ids.each do |id|
      if match_scorers_map.has_key?(id)
        match_scorers_map[id] += 1
      else
        match_scorers_map[id] = 1
      end
    end

    play_scorers_map = {}
    play_scorer_ids.each do |id|
      if play_scorers_map.has_key?(id)
        play_scorers_map[id] += 1
      else
        play_scorers_map[id] = 1
      end
    end

    correct_items = 0
    match_scorers_map.keys.each do |id|
      if play_scorers_map.has_key?(id)
        correct_items += [play_scorers_map[id], match_scorers_map[id]].min
      end
    end

    return correct_items
  end

  def count_correct_team_goals(match_team_goals, play_team_goals)
    correct_items = 0
    match_team_goals.each.with_index do |match_goal, index|
      break if index >= play_team_goals.size
      if match_goal == play_team_goals[index]
        correct_items += 1
      end
    end
    return correct_items
  end

  def simulate
    self.update! status: :in_progress
    self.start!
    sleep(3)
    self.update! status: :finished
    self.finalize!
  end

  def push_to_social_media!
    file_ids = self.highlights
      .where(transfer_status: :done)
      .where.not(file_id: nil)
      .pluck(:file_id)
      
    file_ids.each.with_index do |file_id, index|
      summary_md = "*#{self._home_team['name']} #{self.home_score} - #{self.away_score} #{self._away_team['name']}*\n#{self._league['name']}\n#{self.starts_at.utc.strftime('%b %e - %l:%M %p GMT')}\n#{self.stadium}\n\n*Goals*\n" + self.goals.map { |goal| "#{goal['minute']}\' - #{goal['team'] == 'home' ? self._home_team['name'] : self._away_team['name']} - #{goal['player_name']}" }.join("\n") + "\n\n*Video #{index + 1} of #{file_ids.count}*"
      push_request_body = {
        chat_id: '@guessgoals',
        video: file_id,
        caption: summary_md,
        parse_mode: 'Markdown',
        disable_notification: true
      }
      push_url = "https://api.telegram.org/bot#{ENV['GUESSGOALSBOT_API_TOKEN']}/sendVideo"
      HTTParty.post(push_url, body: push_request_body.to_json, headers: {'Content-Type' => 'application/json'})
    end
    self.update!(pushed_to_social_media: true)
  end

end
