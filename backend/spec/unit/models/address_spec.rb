# == Schema Information
#
# Table name: addresses
#
#  id         :bigint(8)        not null, primary key
#  code       :string
#  internal   :boolean          default(TRUE)
#  used       :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wallet_id  :integer
#
# Indexes
#
#  index_addresses_on_wallet_id  (wallet_id)
#

require 'rails_helper'

RSpec.describe Address, type: :model do

  describe '.expire!' do
    it 'marks address as used' do 
      address = create(:address, used: false)
      address.expire!
      expect(address.used?).to eq(true)
    end

    it 'assigns a new unused address to wallet' do 
      address = create(:address, used: false)
      expect(address.wallet).to receive(:assign_new_address).once
      address.expire!
    end
  end
end
