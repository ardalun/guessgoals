class Admin::DashboardController < AdminController
  
  before_action :require_admin_auth, only: [:index]

  def index

    bitcoin = !!Bitcoin.getblockcount rescue false
    @props = { 
      username: @username,
      sidekiq: system("ps aux | grep '[s]idekiq'"),
      redis: system("ps aux | grep '[r]edis'"),
      postgres: system("ps aux | grep '[p]ostgres'"),
      bitcoin: bitcoin,
      currentBalance: Bitcoin.getbalance,
      users: User.count,
      plays: Play.count,
      transfers: Transfer.count,
      outstanding_payouts: LedgerEntry.where(kind: :payout, status: :processing).count,
      ai_wallet: Wallet.where(id: Wallet.ai.id).serialize(WalletSerializer).first,
      master_wallet: Wallet.where(id: Wallet.master.id).serialize(WalletSerializer).first
    }
  end
end