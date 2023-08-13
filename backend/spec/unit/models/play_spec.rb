# == Schema Information
#
# Table name: plays
#
#  id              :bigint(8)        not null, primary key
#  away_score      :integer          default(0)
#  away_scorers    :jsonb
#  home_score      :integer          default(0)
#  home_scorers    :jsonb
#  payment_status  :integer          default("temp_accepted")
#  team_goals      :jsonb
#  winner_team     :integer          default("draw")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ledger_entry_id :integer
#  match_id        :integer
#  user_id         :integer
#
# Indexes
#
#  index_plays_on_ledger_entry_id  (ledger_entry_id)
#  index_plays_on_match_id         (match_id)
#  index_plays_on_user_id          (user_id)
#

require 'rails_helper'

RSpec.describe Play, type: :model do
  
  describe 'validation: has_valid_scorers' do
    it 'invalidates play when home_score does not equal home_scorers count' do
      play = build(:play, home_score: 1, home_scorers: [])
      expect(play.valid?).to eq(false)
      expect(play.errors[:home_scorers]).to include('count is invalid')
    end

    it 'invalidates play when away_score does not equal away_scorers count' do
      play = build(:play, away_score: 1, away_scorers: [])
      expect(play.valid?).to eq(false)
      expect(play.errors[:away_scorers]).to include('count is invalid')
    end

    it 'invalidates play when home_scorers include scorer_id = nil' do
      play = build(:play, home_score: 1, home_scorers: [{id: nil, name: 'Something'}])
      expect(play.valid?).to eq(false)
      expect(play.errors[:home_scorers]).to include('includes invalid players')
    end

    it 'invalidates play when home_scorers include scorer_name = nil' do
      player = create(:player)
      play = build(:play, home_score: 1, home_scorers: [{id: player.id, name: nil}])
      expect(play.valid?).to eq(false)
      expect(play.errors[:home_scorers]).to include('includes invalid players')
    end

    it 'invalidates play when home_scorers include invalid player name' do
      player = create(:player)
      play = build(:play, home_score: 1, home_scorers: [{id: player.id, name: 'Some Name'}])
      expect(play.valid?).to eq(false)
      expect(play.errors[:home_scorers]).to include('includes invalid players')
    end

    it 'invalidates play when away_scorers include scorer_id = nil' do
      play = build(:play, away_score: 1, away_scorers: [{id: nil, name: 'Something'}])
      expect(play.valid?).to eq(false)
      expect(play.errors[:away_scorers]).to include('includes invalid players')
    end

    it 'invalidates play when away_scorers include scorer_name = nil' do
      player = create(:player)
      play = build(:play, away_score: 1, away_scorers: [{id: player.id, name: nil}])
      expect(play.valid?).to eq(false)
      expect(play.errors[:away_scorers]).to include('includes invalid players')
    end

    it 'invalidates play when away_scorers include invalid player name' do
      player = create(:player)
      play = build(:play, away_score: 1, away_scorers: [{id: player.id, name: 'Some Name'}])
      expect(play.valid?).to eq(false)
      expect(play.errors[:away_scorers]).to include('includes invalid players')
    end

  end

  
  describe 'validation: has_valid_team_goals' do
    it 'invalidates play when sum of total goals are incorrect' do 
      play = build(:play, home_score: 2, away_score: 1, team_goals: ['home', 'away'])
      expect(play.valid?).to eq(false)
      expect(play.errors[:team_goals]).to include('count does not match with sum of home and away goals')
    end

    it 'invalidates play it includes wrong number of home goals' do 
      play = build(:play, home_score: 2, away_score: 1, team_goals: ['home', 'away'])
      expect(play.valid?).to eq(false)
      expect(play.errors[:team_goals]).to include('includes wrong number of home goals')
    end

    it 'invalidates play it includes wrong number of away goals' do 
      play = build(:play, home_score: 2, away_score: 1, team_goals: ['home', 'home', 'away', 'away'])
      expect(play.valid?).to eq(false)
      expect(play.errors[:team_goals]).to include('includes wrong number of away goals')
    end
  end

  
  describe 'validation: has_valid_winner_team' do
    it 'invalidates play when it is a home win but winner is not home' do
      play = build(:play, home_score: 2, away_score: 1, winner_team: 'away')
      expect(play.valid?).to eq(false)
      expect(play.errors[:winner_team]).to include('does not match with home and away goals')
    end

    it 'invalidates play when it is a away win but winner is not away' do
      play = build(:play, home_score: 1, away_score: 2, winner_team: 'home')
      expect(play.valid?).to eq(false)
      expect(play.errors[:winner_team]).to include('does not match with home and away goals')
    end

    it 'invalidates play when it is a draw but winner is not draw' do
      play = build(:play, home_score: 1, away_score: 1, winner_team: 'home')
      expect(play.valid?).to eq(false)
      expect(play.errors[:winner_team]).to include('does not match with home and away goals')
    end
  end

  
  describe 'validation: user_has_sufficient_funds' do
    it 'invalidates play if user has less than ticket fee in their wallet' do
      play = build(:play)
      expect(play.valid?).to eq(false)
      expect(play.errors[:user]).to include('has insufficient funds')
    end

    it 'does not invalidate play for insufficient funds if user has sufficient funds' do
      play = build(:play)
      play.user.wallet.update!(total: play.match.ticket_fee, confirmed: play.match.ticket_fee)
      expect(play.valid?).to eq(true)
    end

    it 'does not invalidate play for insufficient fund if it is AI' do
      play = build(:play, user_id: User.ai.id)
      expect(play.valid?).to eq(true)
    end
  end

  describe 'before_create: user_pays_for_ticket' do
    it 'pays with confirmed credit if there is enough confirmed credit available' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee, confirmed: play.match.ticket_fee)
      play.save!

      payment_entry = play.ledger_entry
      expect(payment_entry.present?).to        be(true)
      expect(payment_entry.ticket_payment?).to be(true)
      expect(payment_entry.total).to           eq(Calc.mult(-1, play.match.ticket_fee))
      expect(payment_entry.confirmed).to       eq(Calc.mult(-1, play.match.ticket_fee))
      expect(payment_entry.is_confirmed?).to   be(true)
    end
    
    it 'pays with unconfirmed credit if there is not enough confirmed credit available' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!

      payment_entry = play.ledger_entry
      expect(payment_entry.present?).to              eq(true)
      expect(payment_entry.total).to                 eq(Calc.mult(-1, play.match.ticket_fee))
      expect(payment_entry.confirmed).to             eq(0)
      expect(payment_entry.pending_confirmation?).to eq(true)
    end
  end
  
  describe 'after_create: try_accepting_payment!' do

    it 'raises error if it is late' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      play.update!(payment_status: :late)
      expect {
        play.try_accepting_payment!
      }.to raise_error(AppError::CannotAcceptLatePlay)
    end

    it 'raises error if it is declined' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      play.update!(payment_status: :declined)
      expect {
        play.try_accepting_payment!
      }.to raise_error(AppError::CannotAcceptDeclinedPlay)
    end

    it 'temporarily accepts play if payment is not yet confirmed' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      expect(play.temp_accepted?).to be(true)
      expect(play.user.notifs.find_by(kind: :play_accepted)).to be(nil)
      expect(play.match.pool_size).to eq(2)
    end

    it 'accepts play, makes notif and increments pool size if payment is confirmed' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee, confirmed: play.match.ticket_fee)
      play.save!
      expect(play.accepted?).to be(true)
      expect(play.user.notifs.find_by(kind: :play_accepted)).not_to be(nil)
      expect(play.match.pool_size).to eq(3)
    end

    it 'raises error if play is already accepted' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee, confirmed: play.match.ticket_fee)
      play.save!
      expect {
        play.try_accepting_payment!
      }.to raise_error(AppError::PlayAlreadyAccepted)
    end
  end

  describe '.decline!' do
    
    it 'raises error if it temp_accepted' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      expect {
        play.decline!
      }.to raise_error(AppError::CannotDeclineNonLatePlay)
    end

    it 'raises error if it accepted' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee, confirmed: play.match.ticket_fee)
      play.save!
      expect {
        play.decline!
      }.to raise_error(AppError::CannotDeclineNonLatePlay)
    end

    it 'raises error if already declined' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      play.update!(payment_status: :declined)
      expect {
        play.decline!
      }.to raise_error(AppError::CannotDeclineNonLatePlay)
    end

    it 'raises error if payment for play is confirmed' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee, confirmed: play.match.ticket_fee)
      play.save!
      play.update!(payment_status: :late)
      expect {
        play.decline!
      }.to raise_error(AppError::CannotDeclinePlayWithConfirmedPayment)
    end

    it 'declines the play only if it is late' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      play.update!(payment_status: :late)
      play.decline!

      expect(play.declined?).to be(true)
    end

    it 'creates play_declined notif' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      play.update!(payment_status: :late)
      play.decline!

      expect(play.declined?).to be(true)
      expect(Notif.find_by(user_id: play.user_id, kind: :play_declined)).not_to be(nil)
    end

    it 'reverses the unconfirmed payment' do
      play = build(:play)
      play.match.update!(pool_size: 2)
      play.user.wallet.update!(total: play.match.ticket_fee)
      play.save!
      play.update!(payment_status: :late)
      expect(play.ledger_entry).to receive(:reverse!)
      play.decline!
    end
  end
end
