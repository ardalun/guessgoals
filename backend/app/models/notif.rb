# == Schema Information
#
# Table name: notifs
#
#  id         :bigint(8)        not null, primary key
#  data       :jsonb
#  kind       :integer          default("funds_received")
#  seen       :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_notifs_on_user_id  (user_id)
#

class Notif < ApplicationRecord
  enum kind: {
    funds_received:        0,
    funds_confirmed:       1,
    funds_declined:        2,
    micro_funds_received:  3,
    micro_funds_confirmed: 4,
    micro_funds_declined:  5,
    play_accepted:         6,
    play_declined:         7,
    match_started:         8,
    pool_won:              9,
    pool_lost:             10,
    payout_requested:      11,
    payout_sent:           12,
    payout_confirmed:      13
  }
  
  belongs_to :user

  validate :data_has_correct_schema, on: :create
  validates_presence_of :user
  
  scope :unseen, -> { where(seen: false) }
  scope :seen,   -> { where(seen: true) }

  after_create :increment_user_unseen_notifs
  after_create_commit :trigger_push
  after_create_commit :send_email

  def data_has_correct_schema
    required_data_keys = []
    
    kind_to_required_keys = {
      funds_received:        ['ledger_entry_id', 'amount'],
      funds_confirmed:       ['ledger_entry_id', 'amount'],
      funds_declined:        ['ledger_entry_id', 'amount'],
      micro_funds_received:  ['ledger_entry_id', 'amount', 'minimum_acceptable_amount'],
      micro_funds_confirmed: ['ledger_entry_id', 'amount'],
      micro_funds_declined:  ['ledger_entry_id', 'amount'],
      play_accepted:         ['play_id', 'match_name'],
      play_declined:         ['play_id', 'match_name'],
      match_started:         ['play_id', 'match_name', 'real_prize', 'real_chance'],
      pool_won:              ['play_id', 'match_name', 'prize_share'],
      pool_lost:             ['play_id', 'match_name', 'play_rank'],
      payout_requested:      ['ledger_entry_id', 'amount'],
      payout_sent:           ['ledger_entry_id', 'amount'],
      payout_confirmed:      ['ledger_entry_id', 'amount']
    }
    
    required_data_keys = kind_to_required_keys[self.kind.to_sym];
    required_data_keys.each do |key|
      if !self.data.key?(key)
        errors.add(:data, "is missing key: #{key}")
      end
    end
  end

  def increment_user_unseen_notifs
    self.user.update!(unseen_notifs: self.user.unseen_notifs + 1)
  end

  def send_email
    if self.funds_received?
      NotifMailer.funds_received(self.id).deliver_later
    elsif self.funds_confirmed?
      NotifMailer.funds_confirmed(self.id).deliver_later
    elsif self.funds_declined?
      NotifMailer.funds_declined(self.id).deliver_later
    elsif self.micro_funds_received?
      NotifMailer.micro_funds_received(self.id).deliver_later
    elsif self.micro_funds_confirmed?
      NotifMailer.micro_funds_confirmed(self.id).deliver_later
    elsif self.micro_funds_declined?
      NotifMailer.micro_funds_declined(self.id).deliver_later
    elsif self.play_accepted?
      NotifMailer.play_accepted(self.id).deliver_later
    elsif self.play_declined?
      NotifMailer.play_declined(self.id).deliver_later
    elsif self.match_started?
      NotifMailer.match_started(self.id).deliver_later
    elsif self.pool_won?
      NotifMailer.pool_won(self.id).deliver_later
    elsif self.pool_lost?
      NotifMailer.pool_lost(self.id).deliver_later
    elsif self.payout_requested?
      NotifMailer.payout_requested(self.id).deliver_later
    elsif self.payout_sent?
      NotifMailer.payout_sent(self.id).deliver_later
    elsif self.payout_confirmed?
      NotifMailer.payout_confirmed(self.id).deliver_later
    end
  end

  def push
    ActionCable.server.broadcast(
      "users/#{self.user_id}/notifs", 
      NotifSerializer.serialize(self)
    )
  end

  def trigger_push
    self.push if !self.payout_requested?
  end
end

