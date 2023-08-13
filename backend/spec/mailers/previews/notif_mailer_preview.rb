# Preview all emails at http://localhost:3000/rails/mailers/notif_mailer
class NotifMailerPreview < ActionMailer::Preview

  def funds_received
    user = FactoryBot.create(:user)
    transfer = FactoryBot.create(
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
    NotifMailer.funds_received(user.notifs.find_by(kind: :funds_received).id)
  end

  def funds_confirmed
    user = FactoryBot.create(:user)
    transfer = FactoryBot.create(
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
    transfer.receive_confirmation!(1)
    NotifMailer.funds_confirmed(user.notifs.find_by(kind: :funds_confirmed).id)
  end

  # def funds_declined
  #   NotifMailer.funds_declined
  # end

  def micro_funds_received
    user = FactoryBot.create(:user)
    transfer = FactoryBot.create(
      :transfer, 
      details: [
        {
          category: 'receive',
          address:  user.wallet.addresses.last.code,
          amount:   '0.0005',
          fee:      '0.0000001'
        }
      ]
    )
    NotifMailer.micro_funds_received(user.notifs.find_by(kind: :micro_funds_received).id)
  end

  def micro_funds_confirmed
    user = FactoryBot.create(:user)
    transfer = FactoryBot.create(
      :transfer, 
      details: [
        {
          category: 'receive',
          address:  user.wallet.addresses.last.code,
          amount:   '0.0005',
          fee:      '0.0000001'
        }
      ]
    )
    transfer.receive_confirmation!(6)
    NotifMailer.micro_funds_confirmed(user.notifs.find_by(kind: :micro_funds_confirmed).id)
  end

  def play_accepted
    user = FactoryBot.create(:user)
    user.wallet.update!(total: 0.001, confirmed: 0.001)
    match = FactoryBot.create(:match, ticket_fee: 0.001, pool_size: 2)
    play = FactoryBot.create(:play, user: user, match: match)
    notif = FactoryBot.create(:notif, kind: :play_accepted, data: { play_id: play.id, match_name: 'Team A vs Team B'})
    NotifMailer.play_accepted(notif.id)
  end

  def play_declined
    notif = FactoryBot.create(:notif, kind: :play_declined, data: { play_id: 0, match_name: 'Team A vs Team B'})
    NotifMailer.play_declined(notif.id)
  end

  def match_started
    notif = FactoryBot.create(:notif, kind: :match_started, data: { play_id: 0, match_name: 'Team A vs Team B', real_chance: 26.0, real_prize: 0.0035})
    NotifMailer.match_started(notif.id)
  end

  def pool_won
    notif = FactoryBot.create(:notif, kind: :pool_won, data: { play_id: 0, match_name: 'Team A vs Team B', prize_share: 0.0035})
    NotifMailer.pool_won(notif.id)
  end

  def pool_lost
    notif = FactoryBot.create(:notif, kind: :pool_lost, data: { play_id: 0, match_name: 'Team A vs Team B', play_rank: 2})
    NotifMailer.pool_lost(notif.id)
  end

  def payout_requested
    notif = FactoryBot.create(:notif, kind: :payout_requested, data: { ledger_entry_id: 0, amount: 0.0035 })
    NotifMailer.payout_requested(notif.id)
  end

  def payout_sent
    user = FactoryBot.create(:user)
    transfer = FactoryBot.create(
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
    NotifMailer.payout_sent(user.notifs.find_by(kind: :funds_received).id)
  end

  def payout_confirmed
    user = FactoryBot.create(:user)
    transfer = FactoryBot.create(
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
    NotifMailer.payout_confirmed(user.notifs.find_by(kind: :funds_received).id)
  end
end