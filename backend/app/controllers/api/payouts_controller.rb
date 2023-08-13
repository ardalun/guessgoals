class Api::PayoutsController < ApiController
  before_action :require_auth, only: [:create]
  
  def create
    user_wallet = Wallet.find_by(owner_type: 'User', owner_id: @current_user_id)
    raise AppError::WalletNotFound if user_wallet.nil?
    
    ledger_entry = user_wallet.payout_to_address!(params[:address])
    render(json: { ledger_entry: ledger_entry.serialize(LedgerEntrySerializer) }, status: 200)
    
  rescue AppError::AddressIsBlank
    render(
      json: {
        error_code: 'validation_failed', 
        validation_errors: { address: ['Address is required. Try again?'] }
      },
      status: 422
    )
  rescue AppError::InvalidBitcoinAddress
    render(
      json: {
        error_code: 'validation_failed', 
        validation_errors: { address: ['This is not a valid address. Try again?'] }
      },
      status: 422
    )
  rescue AppError::AddressIsInternal
    render(
      json: {
        error_code: 'validation_failed', 
        validation_errors: { address: ['This is not an external address. Try again?'] }
      },
      status: 422
    )
  rescue AppError::AddressIsUsed
    render(
      json: {
        error_code: 'validation_failed', 
        validation_errors: { address: ['This address was used before. Try again?'] }
      },
      status: 422
    )
  rescue AppError::NoFundsAvailableForPayout
    render(json: { error_code: 'no_funds_available_for_payout' }, status: 412)
  end

end