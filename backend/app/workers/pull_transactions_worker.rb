class PullTransactionsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  CACHE_KEY = 'LAST_BLOCK_SEEN'

  def perform
    last_block_seen    = Rails.cache.read(CACHE_KEY)
    poll_response      = Bitcoin.listsinceblock(last_block_seen)
    txids              = poll_response.fetch('transactions', []).pluck('txid')
    already_seen_txids = Transfer.where(txid: txids).pluck(:txid)
    unseen_txids       = txids - already_seen_txids
    unconfirmed_txids  = Transfer.where('confirmations < 6').pluck(:txid)
    tobe_checked_txids = (unconfirmed_txids + unseen_txids).uniq
    tobe_checked_txids.each do |txid|
      Bitcoin.delay.check_transaction(txid)
    end
    Rails.cache.write(CACHE_KEY, poll_response.fetch('lastblock', last_block_seen))
  end
end
