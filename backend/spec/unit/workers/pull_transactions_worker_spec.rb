require 'rails_helper'
RSpec.describe PullTransactionsWorker, type: :worker do
  describe '.perform' do
    it 'finds unseen and not fully confirmed txids and push a check_transaction for them to sidekiq' do
      create(:transfer, txid: 'fully_confirmed_seen_one', confirmations: 6)
      create(:transfer, txid: 'not_fully_confirmed_seen_one', confirmations: 2)
      expect(Rails.cache).to receive(:read).and_return('ABC')
      expect(Bitcoin).to receive(:listsinceblock).with('ABC').and_return({
        'transactions' => [
          { 'txid' => 'unseen_one' },
          { 'txid' => 'fully_confirmed_seen_one' }
        ],
        'lastblock' => 'XYZ'
      })
      expect(Rails.cache).to receive(:write).with(PullTransactionsWorker::CACHE_KEY, 'XYZ')
      expect(Bitcoin).to receive(:check_transaction).with('unseen_one')
      expect(Bitcoin).to receive(:check_transaction).with('not_fully_confirmed_seen_one')
      expect(Bitcoin).not_to receive(:check_transaction).with('fully_confirmed_seen_one')
      PullTransactionsWorker.new.perform
    end
  end
end
