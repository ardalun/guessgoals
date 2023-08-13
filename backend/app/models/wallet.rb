# == Schema Information
#
# Table name: wallets
#
#  id         :bigint(8)        not null, primary key
#  confirmed  :float            default(0.0)
#  is_master  :boolean          default(FALSE)
#  locked     :float            default(0.0)
#  owner_type :string
#  total      :float            default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :integer
#
# Indexes
#
#  index_wallets_on_owner_id_and_owner_type  (owner_id,owner_type)
#

class Wallet < ApplicationRecord
  
  belongs_to :owner, polymorphic: true
  has_many   :addresses
  has_many   :ledger_entries

  after_create :assign_new_address
  
  validate :abs_total_not_less_than_locked
  validate :abs_total_not_less_than_confirmed
  validate :master_does_not_have_owner

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

  def master_does_not_have_owner
    if self.is_master? && (self.owner_type.present? || self.owner_id.present?)
      errors.add(:owner, 'cannot be present for a master wallet')
    end
  end
  
  def push
    return if self.owner_type != 'User'
    
    ActionCable.server.broadcast(
      "users/#{self.owner_id}/wallet", 
      DataFactory.make_wallet(self)
    )
  end

  def assign_new_address
    return if self.owner_type != 'User'
    
    Address.create!(wallet_id: self.id, code: Bitcoin.getnewaddress)
  end

  def unconfirmed
    Calc.sub(self.total, self.confirmed)
  end

  def payout_available_amount
    Calc.sub(self.total, self.locked)
  end

  # Returns ledger_entry for the t
  def pay_to!(dest_wallet:, amount:, kind:, add_as_locked: true, accept_unconfirmed: false, src_desc: 'N/A', dest_desc: 'N/A')
    raise AppError::InvalidAmountToSend if amount <= 0
    raise AppError::InvalidPaymentKind if !LedgerEntry.kinds.keys.include?(kind.to_s)

    if self.owner != User.ai
      raise AppError::InsufficientFunds if !accept_unconfirmed && self.confirmed < amount
      raise AppError::InsufficientFunds if self.total < amount
    end
    
    if self.owner == User.ai
      confirmed_transfer_amount = amount
    else
      confirmed_transfer_amount = [amount, self.confirmed].min
    end  

    Db.atomically do
      dest_entry = LedgerEntry.create!(
        kind:          kind,
        status:        amount == confirmed_transfer_amount ? :is_confirmed : :pending_confirmation,
        total:         amount,
        confirmed:     confirmed_transfer_amount,
        locked:        add_as_locked ? amount : 0,
        description:   dest_desc,
        wallet_id:     dest_wallet.id
      )
      src_entry = LedgerEntry.create!(
        kind:          kind,
        status:        amount == confirmed_transfer_amount ? :is_confirmed : :pending_confirmation,
        total:         Calc.mult(-1, amount),
        confirmed:     Calc.mult(-1, confirmed_transfer_amount),
        locked:        Calc.mult(-1, [self.locked, amount].min),
        description:   src_desc,
        wallet_id:     self.id,
        inverse_ledger_entry_id: dest_entry.id
      )
      dest_entry.update!(inverse_ledger_entry_id: src_entry.id)
      return src_entry
    end
  end

  def confirm_credit!(tobe_confirmed_amount)
    raise AppError::TooHighAmountToBeConfirmed if !self.can_confirm_amount(tobe_confirmed_amount)

    Db.atomically do
      self.ledger_entries.unconfirmed_debit.order(:created_at).find_each do |entry|
        tobe_confirmed_amount = entry.confirm_debit!(tobe_confirmed_amount)
        return if tobe_confirmed_amount == 0
      end

      self.update!(confirmed: Calc.add(self.confirmed, tobe_confirmed_amount))
    end
  end

  def can_confirm_amount(tobe_confirmed_amount)
    unconfirmed_debits = self.ledger_entries.unconfirmed_debit.pluck(:total, :confirmed)
    sum = 0
    unconfirmed_debits.each do |debit_total, debit_confirmed|
      debit_unconfirmed = Calc.sub(debit_total, debit_confirmed)
      sum = Calc.add(sum, debit_unconfirmed)
    end
    return tobe_confirmed_amount <= Calc.add(Calc.mult(-1, sum), self.unconfirmed) 
  end

  def self.master
    Wallet.find_or_create_by(is_master: true)
  end

  def self.ai
    User.ai.wallet
  end

  def payout_to_address!(code)
    raise AppError::AddressIsBlank if code.blank?
    raise AppError::InvalidBitcoinAddress if !Bitcoin.is_valid_address?(code)

    existing_address_id, existing_address_internal = Address.where(code: code).pluck(:id, :internal).first
    if Bitcoin.is_internal_address?(code) || existing_address_internal.present?
      raise AppError::AddressIsInternal
    end

    raise AppError::AddressIsUsed if existing_address_id.present?
    raise AppError::NoFundsAvailableForPayout if self.payout_available_amount <= 0
    
    amount = self.payout_available_amount
    amount_neg = Calc.mult(-1, self.payout_available_amount)
    Db.atomically do
      address = Address.create!(
        code:      code,
        internal:  false,
        used:      true,
        wallet_id: self.id,
      )
      ledger_entry = LedgerEntry.create!(
        kind:        :payout,
        status:      :processing,
        total:       amount_neg,
        confirmed:   amount_neg,
        locked:      0,
        acceptable:  true,
        description: 'Payout to external address',
        address_id:  address.id,
        wallet_id:   self.id
      )
      Notif.create!({
        user_id: self.owner_id,
        kind: :payout_requested,
        data: {
          ledger_entry_id: ledger_entry.id,
          amount: amount
        }
      })
      return ledger_entry
    end
  end
end
