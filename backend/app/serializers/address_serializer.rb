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

class AddressSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :code
  ]

  def self.make_hash(raw_array)
    data = super(raw_array)
    data[:qr] = "https://chart.googleapis.com/chart?cht=qr&chs=160x160&chl=#{data[:code]}"
    return data
  end
end
