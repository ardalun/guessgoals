# == Schema Information
#
# Table name: players
#
#  id            :bigint(8)        not null, primary key
#  goals_per_min :float            default(0.0)
#  image_url     :string
#  name          :string
#  number        :integer
#  position      :integer          default("unknown")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sm_id         :string
#  team_id       :integer
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

class PlayerSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :sm_id,
    :name,
    :number,
    :position,
    :image_url,
    :goals_per_min
  ]
end
