# == Schema Information
#
# Table name: wallets
#
#  id          :bigint(8)        not null, primary key
#  confirmed   :float            default(0.0)
#  locked      :float            default(0.0)
#  master      :boolean          default(FALSE)
#  owner_type  :string
#  total       :float            default(0.0)
#  unconfirmed :float            default(0.0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :integer
#
# Indexes
#
#  index_wallets_on_owner_id_and_owner_type  (owner_id,owner_type)
#

require 'rails_helper'

RSpec.describe Wallet, type: :model do
  
  describe 'validation: abs_total_not_less_than_confirmed' do
    it 'invalidates wallet if total absolute value is less than confirmed' do
      wallet = build(:wallet, total: 5, confirmed: 6)
      wallet.validate
      expect(wallet.errors[:total]).to include('cannot be less than confirmed')

      wallet = build(:wallet, total: -5, confirmed: -6)
      wallet.validate
      expect(wallet.errors[:total]).to include('cannot be less than confirmed')
    end
  end

  describe 'validation: abs_total_not_less_than_locked' do
    it 'invalidates wallet if total absolute value is less than locked' do
      wallet = build(:wallet, total: 5, locked: 6)
      wallet.validate
      expect(wallet.errors[:total]).to include('cannot be less than locked')

      wallet = build(:wallet, total: -5, locked: -6)
      wallet.validate
      expect(wallet.errors[:total]).to include('cannot be less than locked')
    end
  end

  describe 'validation: master_does_not_have_owner' do
    it 'invalidates wallet if it is master and has an owner' do
      user = create(:user)
      user.wallet.is_master = true
      user.wallet.validate
      expect(user.wallet.errors[:owner]).to include('cannot be present for a master wallet')
    end
  end

  describe 'after_create: assign_new_address' do
    it 'assigns new bitcoin address on create' do
      user = create(:user)
      expect(user.wallet.addresses.where(used: false).first).to_not be_nil
    end
  end

  describe '.pay_to!' do
    it 'raises exception if amount to send is invalid' do
      src_wallet = create(:wallet)
      dst_wallet = create(:wallet)
      expect { 
        src_wallet.pay_to!(
          dest_wallet: dst_wallet,
          kind: :ticket_payment,
          amount: -1, 
          add_as_locked: false, 
          accept_unconfirmed: false
        )
      }.to raise_error(AppError::InvalidAmountToSend)
    end

    it 'raises exception if payment kind is invalid' do
      src_wallet = create(:wallet)
      dst_wallet = create(:wallet)
      expect { 
        src_wallet.pay_to!(
          dest_wallet: dst_wallet,
          kind: :something,
          amount: 1, 
          add_as_locked: false, 
          accept_unconfirmed: false
        )
      }.to raise_error(AppError::InvalidPaymentKind)
    end

    it 'raises exception when non-ai user tries to spend more than they have' do 
      src_wallet = create(:wallet, total: 5, confirmed: 3)
      dst_wallet = create(:wallet)
      expect { 
        src_wallet.pay_to!(
          dest_wallet: dst_wallet,
          kind: :ticket_payment,
          amount: 6, 
          add_as_locked: false, 
          accept_unconfirmed: true
        ) 
      }.to raise_error(AppError::InsufficientFunds)
    end

    it 'raises exception when non-ai user tries to spend more confirmed amount than they have' do 
      src_wallet = create(:wallet, total: 5, confirmed: 3)
      dst_wallet = create(:wallet)
      expect { 
        src_wallet.pay_to!(
          dest_wallet: dst_wallet,
          kind: :ticket_payment,
          amount: 4, 
          add_as_locked: false, 
          accept_unconfirmed: false
        ) 
      }.to raise_error(AppError::InsufficientFunds)
    end

    it 'makes ai always spend confirmed' do
      src_wallet = User.ai.wallet
      dst_wallet = create(:wallet)
      src_wallet.update!(total: 0.005, confirmed: 0.003)
      src_wallet.pay_to!(
        dest_wallet: dst_wallet,
        kind: :ticket_payment,
        amount: 0.001, 
        add_as_locked: true, 
        accept_unconfirmed: true
      )
      src_wallet.reload
      dst_wallet.reload
      src_ledger_entry = src_wallet.ledger_entries.first
      dst_ledger_entry = dst_wallet.ledger_entries.first

      expect(src_wallet.total).to       eq(0.004)
      expect(src_wallet.confirmed).to   eq(0.002)
      expect(src_wallet.locked).to      eq(0)

      expect(dst_wallet.total).to       eq(0.001)
      expect(dst_wallet.confirmed).to   eq(0.001)
      expect(dst_wallet.locked).to      eq(0.001)

      expect(src_ledger_entry.total).to                eq(-0.001)
      expect(src_ledger_entry.confirmed).to            eq(-0.001)
      expect(src_ledger_entry.ticket_payment?).to      be(true)
      expect(src_ledger_entry.is_confirmed?).to        be(true)
      expect(src_ledger_entry.inverse_ledger_entry).to eq(dst_ledger_entry)

      expect(dst_ledger_entry.total).to                eq(0.001)
      expect(dst_ledger_entry.confirmed).to            eq(0.001)
      expect(dst_ledger_entry.ticket_payment?).to      be(true)
      expect(dst_ledger_entry.is_confirmed?).to        be(true)
      expect(dst_ledger_entry.inverse_ledger_entry).to eq(src_ledger_entry)

    end

    it 'lets ai spent more than it has' do
      src_wallet = User.ai.wallet
      dst_wallet = create(:wallet)
      src_wallet.update!(total: 0.005, confirmed: 0.005)
      src_wallet.pay_to!(
        dest_wallet: dst_wallet,
        kind: :ticket_payment,
        amount: 0.008, 
        add_as_locked: false, 
        accept_unconfirmed: true
      )
      src_wallet.reload
      dst_wallet.reload
      src_ledger_entry = src_wallet.ledger_entries.first
      dst_ledger_entry = dst_wallet.ledger_entries.first

      expect(src_wallet.total).to       eq(-0.003)
      expect(src_wallet.confirmed).to   eq(-0.003)
      expect(src_wallet.locked).to      eq(0)

      expect(dst_wallet.total).to       eq(0.008)
      expect(dst_wallet.confirmed).to   eq(0.008)
      expect(dst_wallet.locked).to      eq(0)
      
      expect(src_ledger_entry.total).to                eq(-0.008)
      expect(src_ledger_entry.confirmed).to            eq(-0.008)
      expect(src_ledger_entry.ticket_payment?).to      be(true)
      expect(src_ledger_entry.is_confirmed?).to        be(true)
      expect(src_ledger_entry.inverse_ledger_entry).to eq(dst_ledger_entry)
      
      expect(dst_ledger_entry.total).to                eq(0.008)
      expect(dst_ledger_entry.confirmed).to            eq(0.008)
      expect(dst_ledger_entry.ticket_payment?).to      be(true)
      expect(dst_ledger_entry.is_confirmed?).to        be(true)
      expect(dst_ledger_entry.inverse_ledger_entry).to eq(src_ledger_entry)

    end

    it 'spends confirmed balance first' do
      src_wallet = create(:wallet, total: 0.005, confirmed: 0.003, locked: 0.002)
      dst_wallet = create(:wallet)
      src_wallet.pay_to!(
        dest_wallet: dst_wallet,
        kind: :ticket_payment,
        amount: 0.0015, 
        add_as_locked: false,
        accept_unconfirmed: true
      )
      src_wallet.reload
      dst_wallet.reload
      src_ledger_entry = src_wallet.ledger_entries.first
      dst_ledger_entry = dst_wallet.ledger_entries.first

      expect(src_wallet.total).to       eq(0.0035)
      expect(src_wallet.confirmed).to   eq(0.0015)
      expect(src_wallet.locked).to      eq(0.0005)

      expect(dst_wallet.total).to       eq(0.0015)
      expect(dst_wallet.confirmed).to   eq(0.0015)
      expect(dst_wallet.locked).to      eq(0)

      expect(src_ledger_entry.total).to                eq(-0.0015)
      expect(src_ledger_entry.confirmed).to            eq(-0.0015)
      expect(src_ledger_entry.ticket_payment?).to      be(true)
      expect(src_ledger_entry.is_confirmed?).to        be(true)
      expect(src_ledger_entry.inverse_ledger_entry).to eq(dst_ledger_entry)

      expect(dst_ledger_entry.total).to                eq(0.0015)
      expect(dst_ledger_entry.confirmed).to            eq(0.0015)
      expect(dst_ledger_entry.ticket_payment?).to      be(true)
      expect(dst_ledger_entry.is_confirmed?).to        be(true)
      expect(dst_ledger_entry.inverse_ledger_entry).to eq(src_ledger_entry)
    end

    it 'spends unconfirmed balance if insufficient confirmed amount' do
      src_wallet = create(:wallet, total: 0.005, confirmed: 0.003, locked: 0.002)
      dst_wallet = create(:wallet)
      src_wallet.pay_to!(
        dest_wallet: dst_wallet,
        kind: :ticket_payment,
        amount: 0.004, 
        add_as_locked: true,
        accept_unconfirmed: true
      )
      src_wallet.reload
      dst_wallet.reload
      src_ledger_entry = src_wallet.ledger_entries.first
      dst_ledger_entry = dst_wallet.ledger_entries.first
      
      expect(src_wallet.total).to       eq(0.001)
      expect(src_wallet.confirmed).to   eq(0)
      expect(src_wallet.locked).to      eq(0)

      expect(dst_wallet.total).to       eq(0.004)
      expect(dst_wallet.confirmed).to   eq(0.003)
      expect(dst_wallet.locked).to      eq(0.004)

      expect(src_ledger_entry.total).to                 eq(-0.004)
      expect(src_ledger_entry.confirmed).to             eq(-0.003)
      expect(src_ledger_entry.ticket_payment?).to       be(true)
      expect(src_ledger_entry.pending_confirmation?).to be(true)
      expect(src_ledger_entry.inverse_ledger_entry).to  eq(dst_ledger_entry)

      expect(dst_ledger_entry.total).to                 eq(0.004)
      expect(dst_ledger_entry.confirmed).to             eq(0.003)
      expect(dst_ledger_entry.ticket_payment?).to       be(true)
      expect(dst_ledger_entry.pending_confirmation?).to be(true)
      expect(dst_ledger_entry.inverse_ledger_entry).to  eq(src_ledger_entry)
    end

    it 'adds fund as locked when flag is set' do
      src_wallet = create(:wallet, total: 0.005, confirmed: 0.003, locked: 0.002)
      dst_wallet = create(:wallet)
      src_wallet.pay_to!(
        dest_wallet: dst_wallet,
        kind: :ticket_payment,
        amount: 0.004, 
        add_as_locked: true,
        accept_unconfirmed: true
      )
      src_wallet.reload
      dst_wallet.reload
      src_ledger_entry = src_wallet.ledger_entries.first
      dst_ledger_entry = dst_wallet.ledger_entries.first
      
      expect(dst_ledger_entry.locked).to eq(0.004)
      expect(src_ledger_entry.locked).to eq(-0.002)
    end

    it 'does not add funds as locked when the flag is not set' do
      src_wallet = create(:wallet, total: 0.005, confirmed: 0.003, locked: 0.002)
      dst_wallet = create(:wallet)
      src_wallet.pay_to!(
        dest_wallet: dst_wallet,
        kind: :ticket_payment,
        amount: 0.004, 
        add_as_locked: false,
        accept_unconfirmed: true
      )
      src_wallet.reload
      dst_wallet.reload
      src_ledger_entry = src_wallet.ledger_entries.first
      dst_ledger_entry = dst_wallet.ledger_entries.first
      
      expect(dst_ledger_entry.locked).to eq(0)
      expect(src_ledger_entry.locked).to eq(-0.002)
    end
  end

  describe '.confirm_credit!' do
    it 'confirms older unconfirmed debits first then newer ones' do
      wallet       = create(:wallet, total: 0.009, confirmed: 0.003)
      oldest_entry = create(:ledger_entry, total: -0.002, confirmed: -0.001, status: :pending_confirmation, wallet_id: wallet.id)
      old_entry    = create(:ledger_entry, total: -0.003, confirmed: -0.001, status: :pending_confirmation, wallet_id: wallet.id)
      latest_entry = create(:ledger_entry, total: -0.004, confirmed: -0.001, status: :pending_confirmation, wallet_id: wallet.id)
      wallet.reload.confirm_credit!(0.0015)
      
      oldest_entry.reload
      old_entry.reload
      latest_entry.reload

      expect(oldest_entry.total).to         eq(-0.002)
      expect(oldest_entry.confirmed).to     eq(-0.002)
      expect(oldest_entry.is_confirmed?).to be(true)

      expect(old_entry.total).to                 eq(-0.003)
      expect(old_entry.confirmed).to             eq(-0.0015)
      expect(old_entry.pending_confirmation?).to be(true)

      expect(latest_entry.total).to                 eq(-0.004)
      expect(latest_entry.confirmed).to             eq(-0.001)
      expect(latest_entry.pending_confirmation?).to be(true)

      expect(wallet.total).to       eq(0)
      expect(wallet.confirmed).to   eq(0)
    end

    it 'confirms all unconfirmed debits then applies confirmation to the wallet if any left' do
      wallet       = create(:wallet, total: 0.01, confirmed: 0.003)
      oldest_entry = create(:ledger_entry, total: -0.002, confirmed: -0.001, status: :pending_confirmation, wallet_id: wallet.id)
      old_entry    = create(:ledger_entry, total: -0.003, confirmed: -0.001, status: :pending_confirmation, wallet_id: wallet.id)
      latest_entry = create(:ledger_entry, total: -0.004, confirmed: -0.001, status: :pending_confirmation, wallet_id: wallet.id)

      wallet.reload.confirm_credit!(0.007)
      
      oldest_entry.reload
      old_entry.reload
      latest_entry.reload

      expect(oldest_entry.total).to         eq(-0.002)
      expect(oldest_entry.confirmed).to     eq(-0.002)
      expect(oldest_entry.is_confirmed?).to be(true)

      expect(old_entry.total).to            eq(-0.003)
      expect(old_entry.confirmed).to        eq(-0.003)
      expect(old_entry.is_confirmed?).to    be(true)

      expect(latest_entry.total).to         eq(-0.004)
      expect(latest_entry.confirmed).to     eq(-0.004)
      expect(latest_entry.is_confirmed?).to be(true)

      expect(wallet.total).to       eq(0.001)
      expect(wallet.confirmed).to   eq(0.001)
    end

    it 'raises exception if sum of unconfirmed debits and wallet unconfirmed is less than tobe_confirmed_value' do
      wallet       = create(:wallet, total: 0.01, confirmed: 0.003)
      oldest_entry = create(:ledger_entry, total: -0.002, confirmed: -0.001, wallet_id: wallet.id)
      old_entry    = create(:ledger_entry, total: -0.003, confirmed: -0.001, wallet_id: wallet.id)
      latest_entry = create(:ledger_entry, total: -0.004, confirmed: -0.001, wallet_id: wallet.id)

      expect {
        wallet.reload.confirm_credit!(0.01)      
      }.to raise_error(AppError::TooHighAmountToBeConfirmed)
    end
  end

  describe '.payout_to_address!' do
    it 'raises error if address is blank' do
      wallet = create(:wallet)
      expect {
        wallet.payout_to_address!('')
      }.to raise_error(AppError::AddressIsBlank)
    end

    it 'raises error if address is app internal' do
      wallet = create(:wallet)
      expect(Bitcoin).to receive(:is_valid_address?).and_return(true)
      expect(Bitcoin).to receive(:is_internal_address?).and_return(false)
      address = create(:address, internal: true)
      expect {
        wallet.payout_to_address!(address.code)
      }.to raise_error(AppError::AddressIsInternal)
    end

    it 'raises error if address exists in the system' do
      wallet = create(:wallet)
      expect(Bitcoin).to receive(:is_valid_address?).and_return(true)
      expect(Bitcoin).to receive(:is_internal_address?).and_return(false)
      address = create(:address, internal: false)
      expect {
        wallet.payout_to_address!(address.code)
      }.to raise_error(AppError::AddressIsUsed)
    end

    it 'raises error if address is bitcoin internal' do
      wallet = create(:wallet)
      expect(Bitcoin).to receive(:is_valid_address?).and_return(true)
      expect(Bitcoin).to receive(:is_internal_address?).and_return(true)
      expect {
        wallet.payout_to_address!('thecode')
      }.to raise_error(AppError::AddressIsInternal)
    end

    it 'raises error if address is not valid' do
      wallet = create(:wallet)
      expect(Bitcoin).to receive(:is_valid_address?).and_return(false)
      expect {
        wallet.payout_to_address!('thecode')
      }.to raise_error(AppError::InvalidBitcoinAddress)
    end

    it 'raises error if funds available for payout is 0' do
      wallet = create(:wallet, total: 0.005, confirmed: 0.005, locked: 0.005)
      expect(Bitcoin).to receive(:is_valid_address?).and_return(true)
      expect(Bitcoin).to receive(:is_internal_address?).and_return(false)
      expect {
        wallet.payout_to_address!('thecode')
      }.to raise_error(AppError::NoFundsAvailableForPayout)
    end

    it 'creates external address, ledger entry and notification' do
      user   = create(:user)
      wallet = user.wallet
      wallet.update!(total: 0.005, confirmed: 0.005, locked: 0)
      expect(Bitcoin).to receive(:is_valid_address?).and_return(true)
      expect(Bitcoin).to receive(:is_internal_address?).and_return(false)
      wallet.payout_to_address!('thecode')

      created_address = Address.find_by(code: 'thecode')
      expect(created_address).not_to       be(nil)
      expect(created_address.internal?).to be(false)
      
      wallet.reload
      expect(wallet.total).to     eq(0)
      expect(wallet.confirmed).to eq(0)
      expect(wallet.locked).to    eq(0)

      payout_entry = wallet.ledger_entries.find_by(kind: :payout)
      expect(payout_entry).not_to         be(nil)
      expect(payout_entry.processing?).to be(true)

      notif = wallet.owner.notifs.where(kind: :payout_requested)
      expect(notif).not_to be(nil)
    end
  end

end
