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

class Player < ApplicationRecord
  enum position: {
		unknown:    0,
    goalkeeper: 1,
    defender:   2,
    midfielder: 3,
    attacker:   4
  }

  enum last_game_role: {
    reserve: 0,
    bench:   1,
    pitch:   2
  }

  belongs_to :team
end
