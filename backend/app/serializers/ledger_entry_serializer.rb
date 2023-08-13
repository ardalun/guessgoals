# == Schema Information
#
# Table name: ledger_entries
#
#  id                      :bigint(8)        not null, primary key
#  acceptable              :boolean          default(TRUE)
#  confirmed               :float
#  description             :string
#  kind                    :integer          default("incoming_transaction")
#  locked                  :float
#  status                  :integer          default("processing")
#  total                   :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  address_id              :integer
#  inverse_ledger_entry_id :integer
#  transfer_id             :integer
#  wallet_id               :integer
#
# Indexes
#
#  index_ledger_entries_on_address_id               (address_id)
#  index_ledger_entries_on_inverse_ledger_entry_id  (inverse_ledger_entry_id)
#  index_ledger_entries_on_transfer_id              (transfer_id)
#  index_ledger_entries_on_wallet_id                (wallet_id)
#

class LedgerEntrySerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :status,
    :total,
    :description,
    :created_at,
    :acceptable
  ]
end
