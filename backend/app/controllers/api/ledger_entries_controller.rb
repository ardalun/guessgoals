class Api::LedgerEntriesController < ApiController
  before_action :require_auth, only: [:index]
  
  RECORDS_PER_PAGE = 10

  def index
    user_wallet_id = Wallet.where(owner_type: 'User', owner_id: @current_user_id).pluck(:id).last

    all_ledger_entries = LedgerEntry.where(wallet: user_wallet_id).order(created_at: :desc)

    ledger_entries = all_ledger_entries
      .offset((params[:page].to_i - 1) * RECORDS_PER_PAGE)
      .limit(RECORDS_PER_PAGE)
      .serialize(LedgerEntrySerializer)

    render(
      status: 200, 
      json: { 
        ledger_entries: ledger_entries,
        current_page: params[:page].to_i,
        records_per_page: RECORDS_PER_PAGE,
        total_records: all_ledger_entries.count
      }
    )
  end

end
