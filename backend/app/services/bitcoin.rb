class Bitcoin
  
  USER = ENV.fetch('BITCOIN_RPC_USER') { 'meysam' }
  PASS = ENV.fetch('BITCOIN_RPC_PASS') { 'dingdong' }
  PORT = ENV.fetch('BITCOIN_RPC_PORT') { '8332' } 
  IP   = ENV.fetch('BITCOIN_RPC_IP')   { '127.0.0.1' } 

  URI = URI.parse("http://#{USER}:#{PASS}@#{IP}:#{PORT}")

  def self.check_transaction(txid)
    tx = self.gettransaction(txid)
    transfer = Transfer.find_by(txid: txid)
    
    if transfer.nil?
      begin
        Transfer.create!(
          txid:          txid,
          amount:        tx.fetch('amount', nil),
          fee:           tx.fetch('fee', nil),
          confirmations: tx.fetch('confirmations', nil),
          details:       tx.fetch('details', nil),
          performed_at:  Time.at(tx.fetch('timereceived', nil))
        )
      rescue ActiveRecord::RecordNotUnique
      end
    else
      new_confirmations = tx.fetch('confirmations', nil)
      transfer.receive_confirmation!(new_confirmations) if new_confirmations.present?
    end
  end

  def self.pull_updates_for_address(address_code)
    pull_response      = self.listreceivedbyaddress(0, true, true, address_code) rescue []
    txids              = pull_response.first&.fetch('txids', [])
    already_seen_txids = Transfer.where(txid: txids).pluck(:txid)
    unseen_txids       = txids - already_seen_txids
    unseen_txids.each do |txid|
      Bitcoin.check_transaction(txid)
    end
    return unseen_txids.size
  end
  
  def self.is_internal_address?(adr)
    self.getaddressesbylabel('').key?(adr)
  end

  def self.is_valid_address?(adr)
    self.validateaddress(adr).fetch('isvalid', false)
  end

  def self.getnewaddress
    if Rails.env.test?
      SecureRandom.hex(10)
    else
      self.method_missing('getnewaddress')
    end
  end

  def self.listsinceblock(*args)
    self.method_missing('listsinceblock', *args)
  end

  def self.listreceivedbyaddress(*args)
    self.method_missing('listreceivedbyaddress', *args)
  end

  def self.gettransaction(*args)
    self.method_missing('gettransaction', *args)
  end

  # fee_rate is in btc_per_kb
  # 0.00001 = 1 satoshi per byte
  def self.send_to_address(address:, amount:, fee_rate:, comment:, comment_to:)
    setting_fee_successful = self.settxfee(fee_rate)
    raise AppError::UnableToSetTxFee if !setting_fee_successful

    return self.sendtoaddress(
      address,
      amount, 
      comment,
      comment_to,
      false,  # Subtract fee from amount
      true,   # Allow this transaction to be replaced by a transaction with higher fees
    )
  end

  def self.method_missing(name, *args)
    post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    resp['result']
  end
 
  def self.http_post_request(post_body)
    http    = Net::HTTP.new(Bitcoin::URI.host, Bitcoin::URI.port)
    request = Net::HTTP::Post.new(Bitcoin::URI.request_uri)
    request.basic_auth Bitcoin::URI.user, Bitcoin::URI.password
    request.content_type = 'application/json'
    request.body = post_body
    http.request(request).body
  end

  class JSONRPCError < RuntimeError
  end
end