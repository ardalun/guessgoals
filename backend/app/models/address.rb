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

class Address < ApplicationRecord
  
  belongs_to :wallet
  has_many   :transfers
  has_many   :ledger_entries

  validates_presence_of :wallet

  def expire!
    Db.atomically do
      self.update!(used: true)
      self.wallet.assign_new_address
    end
  end
end
