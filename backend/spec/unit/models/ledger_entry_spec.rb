# == Schema Information
#
# Table name: ledger_entries
#
#  id                      :bigint(8)        not null, primary key
#  acceptable              :boolean          default(TRUE)
#  confirmed               :float
#  description             :string
#  locked_credit           :boolean          default(TRUE)
#  total                   :float
#  unconfirmed             :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  address_id              :integer
#  reverse_ledger_entry_id :integer
#  transfer_id             :integer
#  wallet_id               :integer
#
# Indexes
#
#  index_ledger_entries_on_address_id               (address_id)
#  index_ledger_entries_on_reverse_ledger_entry_id  (reverse_ledger_entry_id)
#  index_ledger_entries_on_transfer_id              (transfer_id)
#  index_ledger_entries_on_wallet_id                (wallet_id)
#

require 'rails_helper'

RSpec.describe LedgerEntry, type: :model do
  
  it 'defines LedgerEntry::PAYOUT_FEE_RATE = 0.00002' do 
    expect(LedgerEntry::PAYOUT_FEE_RATE).to eq(0.00002)
  end

  describe 'validation: abs_total_not_less_than_confirmed' do
    it 'invalidates ledger_entry if total absolute value is less than confirmed' do
      ledger_entry = build(:ledger_entry, total: 5, confirmed: 6)
      ledger_entry.validate
      expect(ledger_entry.errors[:total]).to include('cannot be less than confirmed')

      ledger_entry = build(:ledger_entry, total: -5, confirmed: -6)
      ledger_entry.validate
      expect(ledger_entry.errors[:total]).to include('cannot be less than confirmed')
    end
  end

  describe 'validation: abs_total_not_less_than_locked' do
    it 'invalidates ledger_entry if total absolute value is less than locked' do
      ledger_entry = build(:ledger_entry, total: 5, locked: 6)
      ledger_entry.validate
      expect(ledger_entry.errors[:total]).to include('cannot be less than locked')

      ledger_entry = build(:ledger_entry, total: -5, locked: -6)
      ledger_entry.validate
      expect(ledger_entry.errors[:total]).to include('cannot be less than locked')
    end
  end

  describe 'validation: validates_presence_of :wallet' do
    it 'validates presence of wallet' do
      ledger_entry = build(:ledger_entry, with_wallet: false)
      ledger_entry.validate
      expect(ledger_entry.errors[:wallet]).to include('can\'t be blank') 
    end
  end

  describe 'after_create: apply_on_wallet' do
    it 'applies confirmed credit on wallet' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0.001)
      expect(ledger_entry.wallet.total).to eq(0.001)
      expect(ledger_entry.wallet.confirmed).to eq(0.001)
    end

    it 'applies confirmed debit on wallet' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: -0.001)
      expect(ledger_entry.wallet.total).to eq(-0.001)
      expect(ledger_entry.wallet.confirmed).to eq(-0.001)
    end
    
    it 'applies unconfirmed credit on wallet' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0)
      expect(ledger_entry.wallet.total).to eq(0.001)
      expect(ledger_entry.wallet.confirmed).to eq(0)
    end
    
    it 'applies unconfirmed debit on wallet' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0)
      expect(ledger_entry.wallet.total).to eq(-0.001)
      expect(ledger_entry.wallet.confirmed).to eq(0)
    end

    it 'applies mix of confirmed and unconfirmed on wallet' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0.0005)
      expect(ledger_entry.wallet.total).to eq(0.001)
      expect(ledger_entry.wallet.confirmed).to eq(0.0005)
    end

    it 'applies locked credit on wallet' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0, locked: 0.001)
      expect(ledger_entry.wallet.locked).to eq(0.001)
    end

    it 'applies non-locked credit on wallet' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0, locked: 0)
      expect(ledger_entry.wallet.locked).to eq(0)
    end

    it 'applies locked debit on wallet' do
      wallet = create(:wallet, total: 0.005, confirmed: 0.003, locked: 0.002)
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0, locked: -0.001, wallet_id: wallet.id)
      expect(ledger_entry.wallet.locked).to eq(0.001)
    end

    it 'applies non-locked debit on wallet' do
      wallet = create(:wallet, total: 0.005, confirmed: 0.003, locked: 0.002)
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: -0.001, wallet_id: wallet.id)
      expect(ledger_entry.wallet.locked).to eq(0.002)
    end
  end

  describe 'after_create_commit: push_wallet' do
    it 'pushes wallet update if applied a change' do
      ledger_entry = build(:ledger_entry, total: 0.001, confirmed: 0.001)
      expect(ledger_entry.wallet).to receive(:push)
      ledger_entry.save!
    end

    it 'does not push wallet update if didn\'t apply a change' do
      expect_any_instance_of(Wallet).to_not receive(:push)
      ledger_entry = build(:ledger_entry, total: 0.001, confirmed: 0.001, acceptable: false)
      expect(ledger_entry.wallet).not_to receive(:push)
      ledger_entry.save!
    end
  end

  describe '.create_funds_received_notif_if_applicable!' do
    it 'does not create notif if not eligible for notif creation' do 
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001,
        confirmed: 0,
        acceptable: true,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      allow(ledger_entry).to receive(:eligible_for_notif_creation?).and_return(false)
      ledger_entry.save!

      expect(user.notifs.count).to eq(0)
    end
  
    it 'creates funds_received notif if acceptable' do
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0,
        acceptable: true,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      allow(ledger_entry).to receive(:eligible_for_notif_creation?).and_return(true)
      ledger_entry.save!

      notif = user.notifs.last
      expect(user.notifs.count).to eq(1)
      expect(notif.kind).to eq('funds_received')
    end

    it 'creates micro_funds_received notif if unacceptable' do
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0,
        acceptable: false,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      allow(ledger_entry).to receive(:eligible_for_notif_creation?).and_return(true)
      ledger_entry.save!

      notif = user.notifs.last
      expect(user.notifs.count).to eq(1)
      expect(notif.kind).to eq('micro_funds_received')
    end
  end

  describe '.create_funds_confirmed_notif_if_applicable!' do
    it 'does not create notif if not eligible for notif creation' do 
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0,
        acceptable: true,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      allow(ledger_entry).to receive(:eligible_for_notif_creation?).and_return(false)
      ledger_entry.save!

      user.notifs.destroy_all
      ledger_entry.create_funds_confirmed_notif_if_applicable!
      
      expect(user.reload.notifs.count).to eq(0)
    end
  
    it 'creates funds_confirmed notif if acceptable' do
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0.001,
        acceptable: true,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      allow(ledger_entry).to receive(:eligible_for_notif_creation?).and_return(true)
      ledger_entry.save!

      user.notifs.destroy_all
      ledger_entry.create_funds_confirmed_notif_if_applicable!
      user.reload

      notif = user.notifs.last
      expect(user.notifs.count).to eq(1)
      expect(notif.kind).to eq('funds_confirmed')
    end

    it 'creates micro_funds_confirmed notif if unacceptable' do
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0.001,
        acceptable: false,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      allow(ledger_entry).to receive(:eligible_for_notif_creation?).and_return(true)
      ledger_entry.save!

      user.notifs.destroy_all
      ledger_entry.create_funds_confirmed_notif_if_applicable!
      user.reload

      notif = user.notifs.last
      expect(user.notifs.count).to eq(1)
      expect(notif.kind).to eq('micro_funds_confirmed')
    end
  end

  describe '.eligible_for_notif_creation?' do
    it 'returns false if address is nil' do
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0,
        acceptable: false,
        address_id: nil,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      expect(ledger_entry.eligible_for_notif_creation?).to eq(false)
    end

    it 'returns false if transfer is nil' do
      user = create(:user)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0,
        acceptable: false,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: nil
      )
      expect(ledger_entry.eligible_for_notif_creation?).to eq(false)
    end

    it 'returns false if it is a debit' do
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: -0.001, 
        confirmed: 0,
        acceptable: false,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      expect(ledger_entry.eligible_for_notif_creation?).to eq(false)
    end

    it 'returns false if wallet owner is not a user' do
      match = create(:match)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0,
        acceptable: false,
        address_id: 22,
        wallet_id: match.wallet.id, 
        transfer_id: nil
      )
      expect(ledger_entry.eligible_for_notif_creation?).to eq(false)
    end

    it 'returns true otherwise' do 
      user = create(:user)
      transfer = create(:transfer)
      ledger_entry = build(
        :ledger_entry, 
        total: 0.001, 
        confirmed: 0,
        acceptable: false,
        address_id: user.wallet.addresses.first.id,
        wallet_id: user.wallet.id, 
        transfer_id: transfer.id
      )
      expect(ledger_entry.eligible_for_notif_creation?).to eq(true)
    end
  end

  describe '.confirm_credit!' do
    it 'raises exception if it is a debit' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0)
      expect { ledger_entry.confirm_credit!(0.001) }.to raise_error(AppError::MustBeCreditEntry)
    end
    
    it 'raises exception if called with a to_be_confirmed argument greater than its unconfirmed amount' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0)
      expect { ledger_entry.confirm_credit!(0.002) }.to raise_error(AppError::TooLowUnconfirmedAmount)
    end
    
    it 'applies partial confirmation and delegates to wallet to confirm that amount too' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0.0005)
      expect(ledger_entry.wallet).to receive(:confirm_credit!).with(0.0002).once
      expect(ledger_entry).to receive(:create_funds_confirmed_notif_if_applicable!)
      ledger_entry.confirm_credit!(0.0002)
      expect(ledger_entry.total).to                 eq(0.001)
      expect(ledger_entry.confirmed).to             eq(0.0007)
      expect(ledger_entry.pending_confirmation?).to be(true)
    end

    it 'applies complete confirmation and delegates to wallet to confirm that amount too' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0)
      expect(ledger_entry.wallet).to receive(:confirm_credit!).with(0.001).once
      expect(ledger_entry).to receive(:create_funds_confirmed_notif_if_applicable!).once
      ledger_entry.confirm_credit!(0.001)
      expect(ledger_entry.total).to         eq(0.001)
      expect(ledger_entry.confirmed).to     eq(0.001)
      expect(ledger_entry.is_confirmed?).to be(true)
    end

    it 'does not delegate to wallet to confirm the amount if this is not an acceptable entry' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0, acceptable: false)
      expect(ledger_entry.wallet).not_to receive(:confirm_credit!)
      expect(ledger_entry).to receive(:create_funds_confirmed_notif_if_applicable!).once
      ledger_entry.confirm_credit!(0.001)
      expect(ledger_entry.total).to         eq(0.001)
      expect(ledger_entry.confirmed).to     eq(0.001)
      expect(ledger_entry.is_confirmed?).to be(true)
    end
  end

  describe '.confirm_debit!' do
    it 'raises exception if it is a credit' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0)
      expect { ledger_entry.confirm_debit!(0.001) }.to raise_error(AppError::MustBeDebitEntry)
    end
    
    it 'applies partial confirmation' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0)
      return_value = ledger_entry.confirm_debit!(0.0005)
      expect(ledger_entry.total).to                 eq(-0.001)
      expect(ledger_entry.confirmed).to             eq(-0.0005)
      expect(ledger_entry.pending_confirmation?).to be(true)
      expect(return_value).to                       eq(0)
    end

    it 'applies complete confirmation' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0)
      return_value = ledger_entry.confirm_debit!(0.001)
      expect(ledger_entry.total).to         eq(-0.001)
      expect(ledger_entry.confirmed).to     eq(-0.001)
      expect(ledger_entry.is_confirmed?).to eq(true)
      expect(return_value).to               eq(0)
    end

    it 'applies excessive confirmation' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0)
      return_value = ledger_entry.confirm_debit!(0.0025)
      expect(ledger_entry.total).to         eq(-0.001)
      expect(ledger_entry.confirmed).to     eq(-0.001)
      expect(ledger_entry.is_confirmed?).to eq(true)
      expect(return_value).to               eq(0.0015)
    end

    it 'returns entire amount to be confirmed if it is already confirmed' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: -0.001)
      return_value = ledger_entry.confirm_debit!(0.0025)
      expect(ledger_entry.total).to         eq(-0.001)
      expect(ledger_entry.confirmed).to     eq(-0.001)
      expect(ledger_entry.is_confirmed?).to eq(true)
      expect(return_value).to               eq(0.0025)
    end

    it 'confirms inverse credit entry' do
      ledger_entry         = create(:ledger_entry, total: -0.001, confirmed: 0)
      inverse_ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0, inverse_ledger_entry_id: ledger_entry.id)
      ledger_entry.update!(inverse_ledger_entry_id: inverse_ledger_entry.id)

      expect(ledger_entry.inverse_ledger_entry).to receive(:confirm_credit!).with(0.001).once
      ledger_entry.confirm_debit!(0.001)
    end

    it 'does not mark the associated play as accepted when it is a partial confirmation' do
      match = create(:match, ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      play = create(:play, user: user, match: match)
      expect(play.ledger_entry.play).not_to receive(:try_accepting_payment!)
      play.ledger_entry.confirm_debit!(0.0005)
    end

    it 'does not mark the associated play as accepted if it is late' do
      match = create(:match, ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      play = create(:play, user: user, match: match)
      play.update!(payment_status: :late)
      expect(play.ledger_entry.play).not_to receive(:try_accepting_payment!)
      play.ledger_entry.confirm_debit!(0.001)
    end
    
    it 'does not mark the associated play as accepted if it is declined' do
      match = create(:match, ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      play = create(:play, user: user, match: match)
      play.update!(payment_status: :declined)
      expect(play.ledger_entry.play).not_to receive(:try_accepting_payment!)
      play.ledger_entry.confirm_debit!(0.001)
    end

    it 'does not mark the associated play as accepted if it is accepted already' do
      match = create(:match, ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      play = create(:play, user: user, match: match)
      play.update!(payment_status: :accepted)
      expect(play.ledger_entry.play).not_to receive(:try_accepting_payment!)
      play.ledger_entry.confirm_debit!(0.001)
    end

    it 'marks the associated play as accepted when it is a complete confirmation' do
      match = create(:match, ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      play = create(:play, user: user, match: match)
      expect(play.ledger_entry.play).to receive(:try_accepting_payment!).once
      play.ledger_entry.confirm_debit!(0.001)
    end

    it 'marks the associated play as accepted when it is an excesive confirmation' do
      match = create(:match, ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      play = create(:play, user: user, match: match)
      expect(play.ledger_entry.play).to receive(:try_accepting_payment!).once
      play.ledger_entry.confirm_debit!(0.004)
    end
  end

  describe 'self.inverse_ledger_entry' do 
    it 'raises exception if kind is not reversible' do
      expect{
        LedgerEntry.reverse_of_kind(:prize_transfer)
      }.to raise_error(AppError::IrreversibleEntryKind)
    end

    it 'returns ticket_payment_rollback for ticket_payment' do
      expect(LedgerEntry.reverse_of_kind('ticket_payment')).to eq('ticket_payment_rollback')
    end
  end

  describe '.reverse!' do
    it 'cancels an unconfirmed debit entry by creating an unconfirmed credit entry' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0, locked: -0.001, status: :pending_confirmation)
      ledger_entry.reverse!
      
      ledger_entry.wallet.reload

      expect(ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_entry = ledger_entry.wallet.ledger_entries.last

      expect(reverse_entry.total).to                 eq(0.001)
      expect(reverse_entry.confirmed).to             eq(0)
      expect(reverse_entry.locked).to                eq(0.001)
      expect(reverse_entry.pending_confirmation?).to be(true)
      expect(reverse_entry.kind).to                  eq(LedgerEntry.reverse_of_kind(ledger_entry.kind).to_s)

      expect(ledger_entry.wallet.total).to     eq(0)
      expect(ledger_entry.wallet.confirmed).to eq(0)
      expect(ledger_entry.wallet.locked).to    eq(0)
    end

    it 'cancels a confirmed debit entry by creating n confirmed credit entry' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: -0.001, locked: -0.001, status: :is_confirmed)
      ledger_entry.reverse!
      
      ledger_entry.wallet.reload

      expect(ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_entry = ledger_entry.wallet.ledger_entries.last

      expect(reverse_entry.total).to         eq(0.001)
      expect(reverse_entry.confirmed).to     eq(0.001)
      expect(reverse_entry.locked).to        eq(0.001)
      expect(reverse_entry.is_confirmed?).to be(true)
      expect(reverse_entry.kind).to          eq(LedgerEntry.reverse_of_kind(ledger_entry.kind).to_s)

      expect(ledger_entry.wallet.total).to     eq(0)
      expect(ledger_entry.wallet.confirmed).to eq(0)
      expect(ledger_entry.wallet.locked).to    eq(0)
    end

    it 'cancels an unconfirmed credit entry by creating an unconfirmed debit entry' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0, locked: 0.001, status: :pending_confirmation)
      ledger_entry.reverse!
      
      ledger_entry.wallet.reload

      expect(ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_entry = ledger_entry.wallet.ledger_entries.last

      expect(reverse_entry.total).to                 eq(-0.001)
      expect(reverse_entry.confirmed).to             eq(0)
      expect(reverse_entry.locked).to                eq(-0.001)
      expect(reverse_entry.pending_confirmation?).to be(true)
      expect(reverse_entry.kind).to                  eq(LedgerEntry.reverse_of_kind(ledger_entry.kind).to_s)

      expect(ledger_entry.wallet.total).to     eq(0)
      expect(ledger_entry.wallet.confirmed).to eq(0)
      expect(ledger_entry.wallet.locked).to    eq(0)
    end

    it 'cancels a confirmed credit entry by creating a confirmed debit entry' do
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0.001, locked: 0.001)
      ledger_entry.reverse!
      
      ledger_entry.wallet.reload

      expect(ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_entry = ledger_entry.wallet.ledger_entries.last

      expect(reverse_entry.total).to         eq(-0.001)
      expect(reverse_entry.confirmed).to     eq(-0.001)
      expect(reverse_entry.locked).to        eq(-0.001)
      expect(reverse_entry.is_confirmed?).to be(true)
      expect(reverse_entry.kind).to          eq(LedgerEntry.reverse_of_kind(ledger_entry.kind).to_s)

      expect(ledger_entry.wallet.total).to     eq(0)
      expect(ledger_entry.wallet.confirmed).to eq(0)
      expect(ledger_entry.wallet.locked).to    eq(0)
    end

    it 'cancels both entry and its inverse by creating an opposite entries' do
      ledger_entry         = create(:ledger_entry, total: -0.001, confirmed: 0, locked: -0.001, status: :pending_confirmation)
      inverse_ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0, status: :pending_confirmation, inverse_ledger_entry_id: ledger_entry.id)
      ledger_entry.update!(inverse_ledger_entry_id: inverse_ledger_entry.id)

      ledger_entry.reverse!
      ledger_entry.wallet.reload
      inverse_ledger_entry.wallet.reload

      expect(ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_entry = ledger_entry.wallet.ledger_entries.last

      expect(inverse_ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_of_inverse = inverse_ledger_entry.wallet.ledger_entries.last
      
      expect(ledger_entry.wallet.total).to     eq(0)
      expect(ledger_entry.wallet.confirmed).to eq(0)
      expect(ledger_entry.wallet.locked).to    eq(0)

      expect(inverse_ledger_entry.wallet.total).to     eq(0)
      expect(inverse_ledger_entry.wallet.confirmed).to eq(0)
      expect(inverse_ledger_entry.wallet.locked).to    eq(0)

      expect(reverse_entry.total).to                 eq(0.001)
      expect(reverse_entry.confirmed).to             eq(0)
      expect(reverse_entry.locked).to                eq(0.001)
      expect(reverse_entry.pending_confirmation?).to be(true)
      expect(reverse_entry.kind).to                  eq(LedgerEntry.reverse_of_kind(ledger_entry.kind).to_s)

      expect(reverse_of_inverse.total).to                 eq(-0.001)
      expect(reverse_of_inverse.confirmed).to             eq(0)
      expect(reverse_of_inverse.locked).to                eq(0)
      expect(reverse_of_inverse.pending_confirmation?).to be(true)
      expect(reverse_of_inverse.kind).to                  eq(LedgerEntry.reverse_of_kind(inverse_ledger_entry.kind).to_s)
    end

    it 'associates reverse of an entry to the reverse of its inverse' do
      ledger_entry         = create(:ledger_entry, total: -0.001, confirmed: 0, locked: -0.001)
      inverse_ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0, inverse_ledger_entry_id: ledger_entry.id)
      ledger_entry.update!(inverse_ledger_entry_id: inverse_ledger_entry.id)

      ledger_entry.reverse!

      expect(ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_entry = ledger_entry.wallet.ledger_entries.last

      expect(inverse_ledger_entry.wallet.ledger_entries.count).to eq(2)
      reverse_of_inverse = inverse_ledger_entry.wallet.ledger_entries.last

      expect(reverse_entry.inverse_ledger_entry_id).to eq(reverse_of_inverse.id)
      expect(reverse_of_inverse.inverse_ledger_entry_id).to eq(reverse_entry.id)
    end
  end

  describe '.approve_payout!' do 
    
    it 'raises error if it is not a payout kind' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0, kind: :ticket_payment)
      expect {
        ledger_entry.approve_payout!
      }.to raise_error(AppError::NonPayoutLedgerEntry)
    end
    
    it 'raises error if it is in pending confirmation state' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: 0, kind: :payout, status: :pending_confirmation)
      expect {
        ledger_entry.approve_payout!
      }.to raise_error(AppError::PayoutMustBeInProcessingState)
    end

    it 'raises error if it is in confirmed state' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: -0.001, kind: :payout, status: :is_confirmed)
      expect {
        ledger_entry.approve_payout!
      }.to raise_error(AppError::PayoutMustBeInProcessingState)
    end
    
    it 'raises error if it is a credit entry' do 
      ledger_entry = create(:ledger_entry, total: 0.001, confirmed: 0.001, kind: :payout, status: :processing)
      expect {
        ledger_entry.approve_payout!
      }.to raise_error(AppError::MustBeDebitEntry)
    end

    it 'raises error if there is no associated address' do
      ledger_entry = create(:ledger_entry, total: -0.001, confirmed: -0.001, kind: :payout, status: :processing)
      expect {
        ledger_entry.approve_payout!
      }.to raise_error(AppError::AddressNotFound)
    end

    it 'sends funds to the associated address, creates transfer and notif and updates entry status and transfer_id' do
      user = create(:user)
      address = create(:address, internal: false, wallet_id: user.wallet.id)
      ledger_entry = create(
        :ledger_entry, 
        total: -0.001, 
        confirmed: -0.001, 
        kind: :payout, 
        status: :processing, 
        address_id: address.id,
        wallet_id: user.wallet.id
      )
      expect(Bitcoin).to receive(:send_to_address).with(
        address:    address.code,
        amount:     0.001,
        fee_rate:   LedgerEntry::PAYOUT_FEE_RATE,
        comment:    "Payout of ledger_entry_id: #{ledger_entry.id}",
        comment_to: "GuessGoals Payout"
      ).and_return('newtxid')

      allow(Bitcoin).to receive(:gettransaction).with('newtxid').and_return({
        "txid"          => 'newtxid',
        "amount"        => -0.001,
        "fee"           => -0.0001,
        "confirmations" => 0,
        "timereceived"  => 1526262948,
        "details"=>[
          {
            "address"  => address.code,
            "category" => 'send',
            "amount"   => -0.001
          }
        ]
      })
      ledger_entry.approve_payout!

      created_transfer = Transfer.find_by(txid: 'newtxid')
      expect(created_transfer).not_to be(nil)
      expect(created_transfer.amount).to        eq(-0.001)
      expect(created_transfer.fee).to           eq(-0.0001)
      expect(created_transfer.confirmations).to eq(0)
      expect(created_transfer.details).to       eq(
        [
          {
            "address"  => address.code,
            "category" => 'send',
            "amount"   => -0.001
          }
        ]
      )
      expect(created_transfer.performed_at).to  eq(Time.at(1526262948))

      created_notif = user.notifs.find_by(kind: :payout_sent)
      expect(created_notif).not_to be(nil)
      expect(ledger_entry.pending_confirmation?).to be(true)
      expect(ledger_entry.transfer_id).to           eq(created_transfer.id)
    end

  end

  describe '.confirm_payout!' do
    it 'raises error if it is not a payout entry' do 
      ledger_entry = create(:ledger_entry, kind: :ticket_payment, total: -0.002, confirmed: 0, locked: 0)
      expect {
        ledger_entry.confirm_payout!
      }.to raise_error(AppError::NonPayoutLedgerEntry)
    end

    it 'raises error if it is not in pending confirmation state' do
      ledger_entry = create(:ledger_entry, kind: :payout, total: -0.002, confirmed: -0.002, locked: 0, status: :is_confirmed)
      expect {
        ledger_entry.confirm_payout!
      }.to raise_error(AppError::PayoutMustBeInPendingConfirmationState)
    end

    it 'confirms the entry and creates payout confirmed notif' do
      user = create(:user)
      ledger_entry = create(
        :ledger_entry, 
        kind: :payout, 
        total: -0.002, 
        confirmed: -0.002, 
        locked: 0, 
        status: :pending_confirmation,
        wallet_id: user.wallet.id
      )
      ledger_entry.confirm_payout!

      payout_confirmed_notif = user.notifs.find_by(kind: :payout_confirmed)
      expect(payout_confirmed_notif).not_to be(nil)
    end
  end

end
