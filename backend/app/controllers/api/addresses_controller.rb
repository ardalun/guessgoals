class Api::AddressesController < ApiController
  before_action :require_auth, only: [:show]
  
  def show
    address = Address.find_hash_by(code: params[:code])
    raise AppError::AddressNotFound if address.nil?

    wallet = Wallet.find_hash_by(id: address[:wallet_id])
    current_user_is_not_owner = wallet[:owner_type] != 'User' || wallet[:owner_id] != @current_user_id
    raise AppError::PermissionDenied if current_user_is_not_owner

    unseen_txids_found = Bitcoin.pull_updates_for_address(address[:code])

    new_wallet = Wallet.find_hash_by(id: address[:wallet_id])
    if unseen_txids_found == 0 || new_wallet[:total] <= wallet[:total]
      render(status: 200, json: { updated: false })
    else
      serialized_wallet = WalletSerializer.serialize(new_wallet)
      serialized_wallet[:address] = Address.find_hash_by(wallet_id: new_wallet[:id], internal: true, used: false)
      render(status: 200, json: { updated: true, wallet: serialized_wallet })
    end
  rescue AppError::AddressNotFound => e
    render(status: 404, json: { error_code: 'address_not_found' })
  rescue AppError::PermissionDenied => e
    render(status: 403, json: { error_code: 'permission_denied' })
  end
  
end