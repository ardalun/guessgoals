require 'rails_helper'

RSpec.describe 'Bitcoin Service', type: :service do
  describe '.check_transaction' do
    before(:each) do
      allow(Bitcoin).to receive(:gettransaction).with('test_txid').and_return({
        "txid"          => 'test_txid',
        "amount"        => 0.001, 
        "confirmations" => 0,
        "timereceived"  => 1526262948,
        "details"=>[
          {
            "address"  => 'test_address_code_1',
            "category" => 'receive',
            "amount"   => 0.005
          },
          {
            "address"  => 'test_address_code_2',
            "category" => 'receive',
            "amount"   => 0.001
          }
        ]
      })
    end

    it 'creates a new transfer if it does not already exist' do
      Bitcoin.check_transaction('test_txid')
      expect(Transfer.count).to eq(1)
      transfer = Transfer.last
      expect(transfer.confirmations).to eq(0)
      expect(transfer.details.size).to  eq(2)

      detail_1 = transfer.details.first
      detail_2 = transfer.details.last

      expect(detail_1.fetch('address', nil)).to  eq('test_address_code_1')
      expect(detail_1.fetch('category', nil)).to eq('receive')
      expect(detail_1.fetch('amount', nil)).to   eq(0.005)

      expect(detail_2.fetch('address', nil)).to  eq('test_address_code_2')
      expect(detail_2.fetch('category', nil)).to eq('receive')
      expect(detail_2.fetch('amount', nil)).to   eq(0.001)
    end

    it 'calls receive_confirmation if it already exists' do
      transfer = create(:transfer, txid: 'test_txid')
      expect(Transfer).to receive(:find_by).and_return(transfer)
      expect(transfer).to receive(:receive_confirmation!)
      Bitcoin.check_transaction('test_txid')
      expect(Transfer.count).to eq(1)
    end  
  end

  describe '.pull_updates_for_address' do
    it 'runs check_transaction for unseen transactions' do
      expect(Bitcoin).to receive(:listreceivedbyaddress).and_return([
        {'txids' => [ 'an_unseen_txid' ]}
      ])
      expect(Bitcoin).to receive(:check_transaction).with('an_unseen_txid')
      Bitcoin.pull_updates_for_address('an_address_code')
    end

    it 'does not run check_transaction for already seen transactions' do
      transfer = create(:transfer)
      expect(Bitcoin).to receive(:listreceivedbyaddress).and_return([
        {'txids' => [ transfer.txid ]}
      ])
      expect(Bitcoin).not_to receive(:check_transaction).with(transfer.txid)
      Bitcoin.pull_updates_for_address('an_address_code')
    end
  end
end