# == Schema Information
#
# Table name: players
#
#  id            :bigint(8)        not null, primary key
#  goals_per_min :float            default(0.0)
#  image_url     :string
#  name          :string
#  position      :integer          default("unknown")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sm_id         :string
#

require 'rails_helper'

RSpec.describe Player, type: :model do
end
