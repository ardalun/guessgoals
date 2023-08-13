# == Schema Information
#
# Table name: wallets
#
#  id         :bigint(8)        not null, primary key
#  confirmed  :float            default(0.0)
#  is_master  :boolean          default(FALSE)
#  locked     :float            default(0.0)
#  owner_type :string
#  total      :float            default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :integer
#
# Indexes
#
#  index_wallets_on_owner_id_and_owner_type  (owner_id,owner_type)
#

class WalletSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :total,
    :confirmed,
    :locked
  ]

  def self.make_hash(raw_array)
    data = super(raw_array)
    data[:unconfirmed] = Calc.sub(data[:total], data[:confirmed])
    data[:unlocked] = Calc.sub(data[:total], data[:locked])
    return data
  end
end
