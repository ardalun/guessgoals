class Admin::PayoutsController < AdminController
  
  before_action :require_admin_auth, only: [:index, :approve]

  def index
    bitcoin = !!Bitcoin.getblockcount rescue false
    records = LedgerEntry.where(kind: :payout, status: :processing).order(:created_at).limit(10).serialize(AdminPayoutSerializer)
    wallets = Wallet.where(id: records.pluck(:wallet_id), owner_type: 'User').quick_indexed_serialize([:id, :owner_id], :id)
    users   = User.where(id: wallets.values.pluck(:owner_id)).quick_indexed_serialize([:id, :username], :id)

    records.each do |record|
      wallet_id = record[:wallet_id]
      user_id = wallets[wallet_id][:owner_id]
      record[:username] = users[user_id][:username]
      record.delete(:wallet_id)
    end
    @props = { 
      username: @username,
      currentBalance: Bitcoin.getbalance,
      total: LedgerEntry.where(kind: :payout).count,
      outstanding: LedgerEntry.where(kind: :payout, status: :processing).count,
      pending: LedgerEntry.where(kind: :payout, status: :pending_confirmation).count,
      confirmed: LedgerEntry.where(kind: :payout, status: :is_confirmed).count,
      records: records
    }
  end

  def approve
    ledger_entry = LedgerEntry.find_by(id: params[:ledger_entry_id])
    raise AppError::LedgerEntryNotFound if ledger_entry.nil?
    ledger_entry.approve_payout!
    head :ok
  rescue AppError::LedgerEntryNotFound
    render(
      json: { 
        error_code: 'ledger_entry_not_found',
        message: 'Ledger entry is not found' 
      }, 
      status: 422
    )
  end

end