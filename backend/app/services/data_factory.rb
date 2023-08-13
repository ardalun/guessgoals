class DataFactory
  def self.make_user(user_instance_or_hash)
    data = UserSerializer.serialize(user_instance_or_hash)
    wallet = Wallet.find_hash_by(owner_type: 'User', owner_id: data[:id])
    data[:wallet] = self.make_wallet(wallet)
    return data
  end

  def self.make_wallet(wallet_instance_or_hash)
    data = WalletSerializer.serialize(wallet_instance_or_hash)
    data[:address] = Address
      .where(wallet_id: data[:id], internal: true, used: false)
      .serialize(AddressSerializer)
      .first
    return data
  end
end