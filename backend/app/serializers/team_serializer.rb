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

class TeamSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :name,
    :handle,
    :code,
    :rank,
    :logo_url
  ]
end
