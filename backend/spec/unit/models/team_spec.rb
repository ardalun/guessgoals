# == Schema Information
#
# Table name: teams
#
#  id         :bigint(8)        not null, primary key
#  code       :string
#  formation  :jsonb
#  handle     :string
#  logo_url   :string
#  name       :string
#  rank       :integer          default(1000)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sm_id      :string
#

require 'rails_helper'

RSpec.describe Team, type: :model do
end
