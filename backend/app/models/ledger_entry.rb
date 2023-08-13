# == Schema Information
#
# Table name: ledger_entries
#
#  id                      :bigint(8)        not null, primary key
#  acceptable              :boolean          default(TRUE)
#  confirmed               :float
#  description             :string
#  kind                    :integer          default("incoming_transaction")
#  locked                  :float
#  status                  :integer          default("processing")
#  total                   :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  address_id              :integer
#  inverse_ledger_entry_id :integer
#  transfer_id             :integer
#  wallet_id               :integer
#
# Indexes
#
#  index_ledger_entries_on_address_id               (address_id)
#  index_ledger_entries_on_inverse_ledger_entry_id  (inverse_ledger_entry_id)
#  index_ledger_entries_on_transfer_id              (transfer_id)
#  index_ledger_entries_on_wallet_id                (wallet_id)
#

class LedgerEntry < ApplicationRecord
  enum kind: {
    incoming_transaction:    0,
    ticket_payment:          1,
    ticket_payment_rollback: 2,
    prize_transfer:          3,
    revenue_transfer:        4,
    payout:                  5
  }

  enum status: {
    processing:           0,
    pending_confirmation: 1,
    is_confirmed:         2
  }
  
  belongs_to :wallet
  belongs_to :inverse_ledger_entry, class_name: 'LedgerEntry', foreign_key: :inverse_ledger_entry_id
  belongs_to :transfer
  belongs_to :address

  has_one :play
  has_one :refund
  has_many :notifs, as: :target

  validates_presence_of :wallet

  validate :abs_total_not_less_than_locked
  validate :abs_total_not_less_than_confirmed

  after_create :apply_on_wallet
  after_create :create_funds_received_notif_if_applicable!
  after_create :create_funds_confirmed_notif_if_applicable!
  after_create_commit :push_wallet

  scope :unconfirmed_credit, -> () { where('total > 0').where(status: :pending_confirmation) }
  scope :unconfirmed_debit, -> () { where('total < 0').where(status: :pending_confirmation) }
  scope :unconfirmed_payout, -> () { where(kind: :payout, status: :pending_confirmation) }

  PAYOUT_FEE_RATE = 0.00002

  def abs_total_not_less_than_confirmed
    if self.total.abs < self.confirmed.abs
      errors.add(:total, 'cannot be less than confirmed')
    end
  end

  def abs_total_not_less_than_locked
    if self.total.abs < self.locked.abs
      errors.add(:total, 'cannot be less than locked')
    end
  end

  def eligible_for_notif_creation?
    return false if self.total < 0
    return false if self.address.nil?
    return false if self.transfer.nil?
    user = self.wallet.owner
    return false if !user.is_a?(User)
    return true
  end

  def create_funds_received_notif_if_applicable!
    return if !self.eligible_for_notif_creation?

    notif_data = {
      ledger_entry_id: self.id,
      amount:          self.total
    }

    Notif.create!(
      kind: self.acceptable ? :funds_received : :micro_funds_received,
      user_id: self.wallet.owner.id,
      data: self.acceptable ? notif_data : notif_data.merge(minimum_acceptable_amount: Rules::MINIMUM_ACCEPTABLE_CREDIT)
    )
  end   

  def create_funds_confirmed_notif_if_applicable!
    return if !self.eligible_for_notif_creation?
    return if self.total != self.confirmed

    owner_type, owner_id = Wallet.where(id: self.wallet_id).pluck(:owner_type, :owner_id).first
    if owner_type == 'User'
      Notif.create!(
        user_id: owner_id,
        kind: self.acceptable ? :funds_confirmed : :micro_funds_confirmed,
        data: {
          ledger_entry_id: self.id,
          amount:          self.total
        }
      )
    end
  end

  def apply_on_wallet
    return if !self.acceptable?
    self.wallet.update!(
      total:       Calc.add(self.total, self.wallet.total),
      confirmed:   Calc.add(self.confirmed, self.wallet.confirmed),
      locked:      Calc.add(self.locked, self.wallet.locked)
    )
    @should_push_wallet = true
  end

  def push_wallet
    self.wallet.push if @should_push_wallet
    @should_push_wallet = false
  end

  def unconfirmed
    Calc.sub(self.total, self.confirmed)
  end

  def confirm_credit!(tobe_confirmed_amount = self.unconfirmed)
    raise AppError::MustBeCreditEntry if self.total < 0
    raise AppError::TooLowUnconfirmedAmount if tobe_confirmed_amount > self.unconfirmed
    Db.atomically do
      new_confirmed = Calc.add(self.confirmed, tobe_confirmed_amount)
      new_status    = new_confirmed == self.total ? :is_confirmed : :pending_confirmation
      self.update!(confirmed: new_confirmed, status: new_status)
      self.create_funds_confirmed_notif_if_applicable!
      self.wallet.confirm_credit!(tobe_confirmed_amount) if self.acceptable?
    end
  end

  def confirm_debit!(available_tobe_confirmed_amount)
    raise AppError::MustBeDebitEntry if self.total > 0
    max_confirmable = self.unconfirmed.abs
    confirming      = [max_confirmable, available_tobe_confirmed_amount].min
    new_confirmed   = Calc.sub(self.confirmed, confirming)
    new_status      = new_confirmed == self.total ? :is_confirmed : :pending_confirmation
    Db.atomically do
      self.update!(confirmed: new_confirmed, status: new_status)
      if self.inverse_ledger_entry.present?
        self.inverse_ledger_entry.confirm_credit!(confirming)
      end
      if self.unconfirmed == 0
        self.play.try_accepting_payment! if self.play.present? && self.play.temp_accepted?
      end
    end
    return Calc.sub(available_tobe_confirmed_amount, confirming)
  end

  def self.reverse_of_kind(kind)
    map = {
      'ticket_payment' => 'ticket_payment_rollback'
    }
    raise AppError::IrreversibleEntryKind if map.keys.exclude?(kind)
    return map[kind]
  end

  def reverse!
    Db.atomically do
      reverse_entry = LedgerEntry.create!(
        acceptable:    self.acceptable?,
        kind:          LedgerEntry.reverse_of_kind(self.kind),
        status:        self.status,
        total:         Calc.mult(-1, self.total),
        confirmed:     Calc.mult(-1, self.confirmed),
        locked:        Calc.mult(-1, self.locked),
        description:   "#{self.description} Reversed",
        wallet_id:     self.wallet_id
      )
      if self.inverse_ledger_entry.present?
        reverse_of_inverse_entry = LedgerEntry.create!(
          acceptable:    self.inverse_ledger_entry.acceptable?,
          kind:          LedgerEntry.reverse_of_kind(self.inverse_ledger_entry.kind),
          status:        self.inverse_ledger_entry.status,
          total:         Calc.mult(-1, self.inverse_ledger_entry.total),
          confirmed:     Calc.mult(-1, self.inverse_ledger_entry.confirmed),
          locked:        Calc.mult(-1, self.inverse_ledger_entry.locked),
          description:   "#{self.inverse_ledger_entry.description} Reversed",
          wallet_id:     self.inverse_ledger_entry.wallet_id,
          inverse_ledger_entry_id: reverse_entry.id
        )
        reverse_entry.update!(inverse_ledger_entry_id: reverse_of_inverse_entry.id)
      end
    end
  end

  def approve_payout!
    raise AppError::NonPayoutLedgerEntry if !self.payout?
    raise AppError::PayoutMustBeInProcessingState if !self.processing?
    raise AppError::MustBeDebitEntry if self.total > 0
    raise AppError::AddressNotFound if self.address.nil?

    txid = nil
    Db.atomically do
      self.update!(status: :pending_confirmation)
      txid = Bitcoin.send_to_address(
        address:    self.address.code,
        amount:     Calc.mult(-1, self.total),
        fee_rate:   LedgerEntry::PAYOUT_FEE_RATE,
        comment:    "Payout of ledger_entry_id: #{self.id}",
        comment_to: "GuessGoals Payout"
      )
    end
    
    Bitcoin.check_transaction(txid)

    Db.atomically do
      transfer_id = Transfer.where(txid: txid).pluck(:id).first
      self.update!(transfer_id: transfer_id)
      owner_type, owner_id = Wallet.where(id: self.wallet_id).pluck(:owner_type, :owner_id).first
      if owner_type == 'User'
        Notif.create!({
          user_id: owner_id,
          kind: :payout_sent,
          data: {
            ledger_entry_id: self.id,
            amount: Calc.mult(-1, self.total)
          }
        })
      end
    end
  end

  def confirm_payout!
    raise AppError::NonPayoutLedgerEntry if !self.payout?
    raise AppError::PayoutMustBeInPendingConfirmationState if !self.pending_confirmation?

    Db.atomically do
      self.update!(status: :is_confirmed)

      owner_type, owner_id = Wallet.where(id: self.wallet_id).pluck(:owner_type, :owner_id).first
      if owner_type == 'User'
        Notif.create!(
          user_id: owner_id,
          kind: :payout_confirmed,
          data: {
            ledger_entry_id: self.id,
            amount:          Calc.mult(-1, self.total)
          }
        )
      end
    end
  end

end
