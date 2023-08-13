# == Schema Information
#
# Table name: transfers
#
#  id            :bigint(8)        not null, primary key
#  amount        :float
#  confirmations :integer          default(0)
#  details       :jsonb
#  fee           :float
#  performed_at  :datetime
#  txid          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_transfers_on_txid  (txid) UNIQUE
#

class Transfer < ApplicationRecord
  has_one :refund
  has_many :ledger_entries

  after_create :make_ledger_entries

  def make_ledger_entries
    self.details.each do |detail|
      category     = detail.fetch('category', nil)
      address_code = detail.fetch('address', nil)
      amount       = detail.fetch('amount', nil)
      fee          = detail.fetch('fee', nil)

      next if address_code.nil? || amount.nil?

      if category == 'send'
        SlackApp.delay.notify_sending_bitcoin(
          amount,
          address_code,
          self.txid,
          self.performed_at.in_time_zone('America/Toronto').to_s
        )
        next
      end
      
      address = Address.find_by(code: address_code)
      if address.nil?
        SlackApp.delay.notify_receiving_bitcoin_on_nonapp_address(
          amount, 
          address_code, 
          self.txid,
          self.performed_at.in_time_zone('America/Toronto').to_s
        )
        next
      end
      
      acceptable = amount.to_f >= Rules::MINIMUM_ACCEPTABLE_CREDIT
      Db.atomically do
        address.expire!
        confirm_it = should_confirm_credit_entry?(acceptable)
        ledger_entry = LedgerEntry.create!(
          kind:        :incoming_transaction,
          status:      confirm_it ? :is_confirmed : :pending_confirmation,
          total:       amount,
          confirmed:   confirm_it ? amount : 0,
          locked:      amount,
          description: "Incoming transaction",
          acceptable:  acceptable,
          address_id:  address.id,
          wallet_id:   address.wallet_id,
          transfer_id: self.id
        )
        self.ledger_entries << ledger_entry
      end

      SlackApp.delay.notify_receiving_bitcoin_on_app_address(
        amount,
        address_code, 
        self.txid,
        self.performed_at.in_time_zone('America/Toronto').to_s
      )
    end
  end

  def receive_confirmation!(new_confirmations)
    return if self.confirmations == new_confirmations.to_i
    return if self.confirmations >= 6

    Db.atomically do
      self.update!(confirmations: new_confirmations < 6 ? new_confirmations : 6)
      self.ledger_entries.unconfirmed_credit.find_each do |entry|
        entry.confirm_credit! if self.should_confirm_credit_entry?(entry.acceptable)
      end
      self.ledger_entries.unconfirmed_payout.find_each do |entry|
        entry.confirm_payout!
      end
    end
    
    if [1, 6].include?(self.confirmations)
      SlackApp.delay.notify_receiving_transaction_confirmation(
        self.txid,
        self.performed_at.in_time_zone('America/Toronto').to_s,
        self.confirmations
      )
    end
  end

  def should_confirm_credit_entry?(acceptable)
    confirmed_acceptable = acceptable && self.confirmations > 0
    confirmed_unacceptable = !acceptable && self.confirmations >= 6
    return confirmed_acceptable || confirmed_unacceptable
  end

end
