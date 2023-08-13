# == Schema Information
#
# Table name: refunds
#
#  id              :bigint(8)        not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ledger_entry_id :integer
#  transfer_id     :integer
#
# Indexes
#
#  index_refunds_on_ledger_entry_id  (ledger_entry_id)
#  index_refunds_on_transfer_id      (transfer_id)
#

require 'rails_helper'

RSpec.describe Refund, type: :model do
end
