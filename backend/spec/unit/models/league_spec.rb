# == Schema Information
#
# Table name: leagues
#
#  id         :bigint(8)        not null, primary key
#  active     :boolean          default(FALSE)
#  handle     :string
#  logo_url   :string
#  name       :string
#  sort_order :integer          default(1000)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  season_id  :integer
#  sm_id      :string
#
# Indexes
#
#  index_leagues_on_season_id  (season_id)
#

require 'rails_helper'

RSpec.describe League, type: :model do
end
