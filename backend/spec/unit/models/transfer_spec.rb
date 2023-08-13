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
#  payout_id     :integer
#
# Indexes
#
#  index_transfers_on_payout_id  (payout_id)
#

require 'rails_helper'

RSpec.describe Transfer, type: :model do
  describe 'after_create: make_ledger_entries' do
    it 'sends slack notification if it finds a send' do
      expect(SlackApp).to receive(:notify_sending_bitcoin)
      create(
        :transfer,
        details: [
          {
            category: 'send',
            address:  'whatever',
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
    end

    it 'sends slack notification if it finds a receive on non-app-address' do
      expect(SlackApp).to receive(:notify_receiving_bitcoin_on_nonapp_address)
      create(
        :transfer,
        details: [
          {
            category: 'receive',
            address:  'whatever',
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
    end

    it 'creates an unacceptable ledger entry if amount is less than minimum acceptable' do 
      user = create(:user)
      stub_const("Rules::MINIMUM_ACCEPTABLE_CREDIT", 0.001)
      expect(SlackApp).to receive(:notify_receiving_bitcoin_on_app_address)
      expect(SlackApp).not_to receive(:notify_receiving_bitcoin_on_nonapp_address)
      create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.0005',
            fee:      '0.0000001'
          }
        ]
      )
      user.reload
      expect(user.wallet.ledger_entries.count).to eq(1)
      ledger_entry = user.wallet.ledger_entries.last
      expect(ledger_entry.acceptable?).to eq(false)
      expect(ledger_entry.incoming_transaction?).to be(true)
    end

    it 'creates an acceptable ledger entry if amount is greater than minimum acceptable' do 
      user = create(:user)
      stub_const("Rules::MINIMUM_ACCEPTABLE_CREDIT", 0.001)
      expect(SlackApp).to receive(:notify_receiving_bitcoin_on_app_address)
      expect(SlackApp).not_to receive(:notify_receiving_bitcoin_on_nonapp_address)
      create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      user.reload
      expect(user.wallet.ledger_entries.count).to eq(1)
      ledger_entry = user.wallet.ledger_entries.last
      expect(ledger_entry.acceptable?).to eq(true)
      expect(ledger_entry.incoming_transaction?).to be(true)
    end

    it 'creates a confirmed ledger entry when it should confirm' do 
      user = create(:user)
      transfer = build(
        :transfer,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      expect(transfer).to receive(:should_confirm_credit_entry?).and_return(true)
      expect(SlackApp).to receive(:notify_receiving_bitcoin_on_app_address)
      expect(SlackApp).not_to receive(:notify_receiving_bitcoin_on_nonapp_address)
      transfer.save!
      user.reload
      expect(user.wallet.ledger_entries.count).to eq(1)
      ledger_entry = user.wallet.ledger_entries.last
      expect(ledger_entry.confirmed?).to            be(true)
      expect(ledger_entry.incoming_transaction?).to be(true)
      expect(ledger_entry.total).to                 eq(0.001)
      expect(ledger_entry.unconfirmed).to           eq(0)
      expect(ledger_entry.confirmed).to             eq(0.001)
    end

    it 'creates an unconfirmed ledger entry when it should not confirm' do 
      user = create(:user)
      transfer = build(
        :transfer,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      expect(transfer).to receive(:should_confirm_credit_entry?).and_return(false)
      expect(SlackApp).to receive(:notify_receiving_bitcoin_on_app_address)
      expect(SlackApp).not_to receive(:notify_receiving_bitcoin_on_nonapp_address)
      transfer.save!
      user.reload
      expect(user.wallet.ledger_entries.count).to eq(1)
      ledger_entry = user.wallet.ledger_entries.last
      expect(ledger_entry.pending_confirmation?).to be(true)
      expect(ledger_entry.incoming_transaction?).to be(true)
      expect(ledger_entry.total).to                 eq(0.001)
      expect(ledger_entry.unconfirmed).to           eq(0.001)
      expect(ledger_entry.confirmed).to             eq(0)
    end

    it 'expires the receiving address' do
      user = create(:user)
      stub_const("Rules::MINIMUM_ACCEPTABLE_CREDIT", 0.001)
      create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      user.reload
      expect(user.wallet.ledger_entries.count).to eq(1)
      ledger_entry = user.wallet.ledger_entries.last
      expect(ledger_entry.address.used?).to eq(true)
    end

    it 'does not create entries if amount = nil' do
      user = create(:user)
      stub_const("Rules::MINIMUM_ACCEPTABLE_CREDIT", 0.001)
      expect(SlackApp).not_to receive(:notify_sending_bitcoin)
      expect(SlackApp).not_to receive(:notify_receiving_bitcoin_on_nonapp_address)
      create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   nil,
            fee:      '0.0000001'
          }
        ]
      )
      user.reload
      expect(user.wallet.ledger_entries.count).to eq(0)
    end

    it 'does not create entries if address_code = nil' do
      stub_const("Rules::MINIMUM_ACCEPTABLE_CREDIT", 0.001)
      expect(SlackApp).not_to receive(:notify_sending_bitcoin)
      expect(SlackApp).not_to receive(:notify_receiving_bitcoin_on_nonapp_address)
      create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  nil,
            amount:   nil,
            fee:      '0.0000001'
          }
        ]
      )
      expect(LedgerEntry.count).to eq(0)
    end
  end

  describe '.should_confirm_credit_entry?' do
    it 'returns false for acceptables when confirmations = 0' do
      transfer = create(:transfer, confirmations: 0)
      expect(transfer.should_confirm_credit_entry?(true)).to eq(false)
    end

    it 'returns false for unacceptables when confirmations < 6' do
      transfer = create(:transfer, confirmations: 5)
      expect(transfer.should_confirm_credit_entry?(false)).to eq(false)
    end

    it 'returns true for acceptables when confirmations > 0' do
      transfer = create(:transfer, confirmations: 1)
      expect(transfer.should_confirm_credit_entry?(true)).to eq(true)
    end

    it 'returns true for unacceptables when confirmations >= 6' do
      transfer = create(:transfer, confirmations: 6)
      expect(transfer.should_confirm_credit_entry?(true)).to eq(true)
    end
  end

  describe '.receive_confirmation!' do
    it 'updates confirmations to the new value if new value is < 6' do
      transfer = create(:transfer, confirmations: 0)
      transfer.receive_confirmation!(1)
      expect(transfer.confirmations).to eq(1)
    end

    it 'updates confirmations to 6 if new value is >= 6' do
      transfer = create(:transfer, confirmations: 0)
      transfer.receive_confirmation!(8)
      expect(transfer.confirmations).to eq(6)
    end

    it 'sends slack notification if confirmation changed to 1' do 
      transfer = create(:transfer, confirmations: 0)
      expect(SlackApp).to receive(:notify_receiving_transaction_confirmation)
      transfer.receive_confirmation!(1)
    end

    it 'sends slack notification if confirmation changed to 6' do 
      transfer = create(:transfer, confirmations: 0)
      expect(SlackApp).to receive(:notify_receiving_transaction_confirmation)
      transfer.receive_confirmation!(6)
    end

    it 'does not send slack notification if confirmation changed to anything between 1 and 6' do 
      transfer = create(:transfer, confirmations: 0)
      expect(SlackApp).not_to receive(:notify_receiving_transaction_confirmation)
      transfer.receive_confirmation!(3)
    end

    it 'does not make any updates if confirmations not changed' do
      transfer = create(:transfer, confirmations: 1)
      transfer.receive_confirmation!(1)
      expect(transfer.confirmations).to eq(1)
      expect(SlackApp).not_to receive(:notify_receiving_transaction_confirmation)
      expect(transfer).not_to receive(:should_confirm_credit_entry?)
    end

    it 'does not make any updates if confirmation is already >= 6' do
      transfer = create(:transfer, confirmations: 6)
      transfer.receive_confirmation!(7)
      expect(transfer.confirmations).to eq(6)
      expect(SlackApp).not_to receive(:notify_receiving_transaction_confirmation)
      expect(transfer).not_to receive(:should_confirm_credit_entry?)
    end


    it 'confirms unconfirmed credit entries if it should' do
      transfer = create(:transfer, confirmations: 0)
      ledger_entry_1 = create(
        :ledger_entry,
        total: 0.001,
        confirmed: 0,
        status: :pending_confirmation,
        transfer_id: transfer.id
      )
      ledger_entry_2 = create(
        :ledger_entry,
        total: 0.002,
        confirmed: 0,
        status: :pending_confirmation,
        transfer_id: transfer.id
      )
      expect(transfer).to receive(:should_confirm_credit_entry?).exactly(2).times.and_return(true)
      transfer.receive_confirmation!(1)

      ledger_entry_1.reload
      ledger_entry_2.reload

      expect(ledger_entry_1.total).to       eq(0.001)
      expect(ledger_entry_1.confirmed).to   eq(0.001)

      expect(ledger_entry_2.total).to       eq(0.002)
      expect(ledger_entry_2.confirmed).to   eq(0.002)
    end

    it 'confirms unconfirmed payout entries' do
      transfer = create(:transfer, confirmations: 0)
      ledger_entry = create(
        :ledger_entry,
        kind: :payout,
        total: -0.002,
        confirmed: -0.002,
        status: :pending_confirmation,
        transfer_id: transfer.id
      )
      expect(transfer).not_to receive(:should_confirm_credit_entry?)
      transfer.receive_confirmation!(1)

      ledger_entry.reload

      expect(ledger_entry.total).to         eq(-0.002)
      expect(ledger_entry.confirmed).to     eq(-0.002)
      expect(ledger_entry.is_confirmed?).to be(true)
    end

    it 'does not confirm unconfirmed credit entries if it should not' do
      transfer = create(:transfer, confirmations: 0)
      ledger_entry_1 = create(
        :ledger_entry,
        total: 0.001,
        confirmed: 0,
        status: :pending_confirmation,
        transfer_id: transfer.id
      )
      ledger_entry_2 = create(
        :ledger_entry,
        total: 0.002,
        confirmed: 0,
        status: :pending_confirmation,
        transfer_id: transfer.id
      )
      expect(transfer).to receive(:should_confirm_credit_entry?).exactly(2).times.and_return(false)
      transfer.receive_confirmation!(1)

      ledger_entry_1.reload
      ledger_entry_2.reload

      expect(ledger_entry_1.total).to                 eq(0.001)
      expect(ledger_entry_1.confirmed).to             eq(0)
      expect(ledger_entry_1.pending_confirmation?).to be(true)

      expect(ledger_entry_2.total).to                 eq(0.002)
      expect(ledger_entry_2.confirmed).to             eq(0)
      expect(ledger_entry_2.pending_confirmation?).to be(true)
    end
  end
end
