class NotifMailer < ApplicationMailer
  default from: 'GuessGoals <support@mail.guessgoals.com>'
  layout 'mailer'

  def funds_received(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    @txid, performed_at, @address = LedgerEntry
      .joins(:transfer, :address)
      .where(id: data['ledger_entry_id'])
      .pluck('transfers.txid', 'transfers.performed_at', 'addresses.code').first
    @performed_at = performed_at.utc.strftime('%Y-%m-%d %l:%M %p GMT') 
    mail(to: @to, subject: 'New Credit Transaction')
  end

  def funds_confirmed(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    @txid, performed_at, @address = LedgerEntry
      .joins(:transfer, :address)
      .where(id: data['ledger_entry_id'])
      .pluck('transfers.txid', 'transfers.performed_at', 'addresses.code').first
    @performed_at = performed_at.utc.strftime('%Y-%m-%d %l:%M %p GMT') 
    mail(to: @to, subject: 'Your Transaction was Confirmed')
  end

  def funds_declined(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    @txid, performed_at, @address = LedgerEntry
      .joins(:transfer, :address)
      .where(id: data['ledger_entry_id'])
      .pluck('transfers.txid', 'transfers.performed_at', 'addresses.code').first
    @performed_at = performed_at.utc.strftime('%Y-%m-%d %l:%M %p GMT') 
    mail(to: @to, subject: 'Your Transaction was Declined')
  end

  def micro_funds_received(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    @minimum_acceptable_amount = data['minimum_acceptable_amount']
    @txid, performed_at, @address = LedgerEntry
      .joins(:transfer, :address)
      .where(id: data['ledger_entry_id'])
      .pluck('transfers.txid', 'transfers.performed_at', 'addresses.code').first
    @performed_at = performed_at.utc.strftime('%Y-%m-%d %l:%M %p GMT') 
    mail(to: @to, subject: 'Unacceptable Credit Transaction')
  end

  def micro_funds_confirmed(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    @txid, performed_at, @address = LedgerEntry
      .joins(:transfer, :address)
      .where(id: data['ledger_entry_id'])
      .pluck('transfers.txid', 'transfers.performed_at', 'addresses.code').first
    @performed_at = performed_at.utc.strftime('%Y-%m-%d %l:%M %p GMT')
    mail(to: @to, subject: 'Unacceptable Transaction Ready for Refund')
  end

  def play_accepted(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @match_name = data['match_name']
    
    starts_at = Play
      .joins(:match)
      .where(id: data['play_id'])
      .pluck('matches.starts_at').first

    @match_date = starts_at.strftime('%B %e')
    @match_time = starts_at.utc.strftime('%l:%M %p GMT')
    mail(to: @to, subject: 'Your Bet is Confirmed')
  end

  def play_declined(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @match_name = data['match_name']
    mail(to: @to, subject: 'Your Bet is Declined')
  end

  def match_started(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @match_name = data['match_name']
    @real_prize = data['real_prize']
    @real_chance = data['real_chance'] > 1 ? data['real_chance'].round : data['real_chance']
    mail(to: @to, subject: 'Match Started')
  end

  def pool_won(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @match_name = data['match_name']
    @prize_share = data['prize_share']
    @subject = "Congratulations! You Won #{data['prize_share']} BTC"
    mail(to: @to, subject: @subject)
  end

  def pool_lost(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @match_name = data['match_name']
    play_rank = data['play_rank']
    suffix = 'th'
    if play_rank == 2
      suffix = 'nd'
    elsif play_rank == 3
      suffix = 'rd'
    end
    @play_rank = "#{play_rank}#{suffix}"
    @subject = "Your Bet Was Ranked #{@play_rank}"
    mail(to: @to, subject: @subject)
  end

  def payout_requested(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    mail(to: @to, subject: "We Are Processing Your Payout Request")
  end

  def payout_sent(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    @txid, performed_at, @address = LedgerEntry
      .joins(:transfer, :address)
      .where(id: data['ledger_entry_id'])
      .pluck('transfers.txid', 'transfers.performed_at', 'addresses.code').first
    @performed_at = performed_at.utc.strftime('%Y-%m-%d %l:%M %p GMT')
    mail(to: @to, subject: "We Sent Your Bitcoin")
  end

  def payout_confirmed(notif_id)
    data, @to = Notif.joins(:user).where(id: notif_id).pluck(:data, 'users.email').first
    @amount = data['amount']
    @txid, performed_at, @address = LedgerEntry
      .joins(:transfer, :address)
      .where(id: data['ledger_entry_id'])
      .pluck('transfers.txid', 'transfers.performed_at', 'addresses.code').first
    @performed_at = performed_at.utc.strftime('%Y-%m-%d %l:%M %p GMT')
    mail(to: @to, subject: "Your Payout Transaction is Confirmed")
  end
end