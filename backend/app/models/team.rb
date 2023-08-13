# == Schema Information
#
# Table name: teams
#
#  id                :bigint(8)        not null, primary key
#  code              :string
#  formation         :string
#  formation_players :jsonb
#  handle            :string
#  logo_url          :string
#  name              :string
#  rank              :integer          default(1000)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sm_id             :string
#

class Team < ApplicationRecord
  has_many :home_matches, class_name: 'Match', foreign_key: :home_team_id
  has_many :away_matches, class_name: 'Match', foreign_key: :away_team_id
  has_many :players
  has_and_belongs_to_many :seasons

  def seed_formation
    goal_keeper = []
    defenders   = []
    midfielders = []
    attackers   = []
    bench       = []

    self.players.serialize(PlayerSerializer)
      .sort_by { |item| item[:number].blank? ? 100000 : item[:number] }
      .each do |player|
        if player[:position] == 'goalkeeper' && goal_keeper.count < 1
          goal_keeper << player
        elsif player[:position] == 'defender' && defenders.count < 4
          defenders << player
        elsif player[:position] == 'midfielder' && midfielders.count < 4
          midfielders << player
        elsif player[:position] == 'attacker' && attackers.count < 2
          attackers << player
        elsif bench.count < 7
          bench << player
        end
      end
    
    formation_players = goal_keeper + defenders + midfielders + attackers + bench
    self.update!(formation: '4-4-2', formation_players: formation_players)
  end
end
