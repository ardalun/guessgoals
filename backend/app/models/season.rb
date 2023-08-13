# == Schema Information
#
# Table name: seasons
#
#  id         :bigint(8)        not null, primary key
#  current    :boolean          default(FALSE)
#  stage      :string
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  league_id  :integer
#  sm_id      :string
#
# Indexes
#
#  index_seasons_on_league_id  (league_id)
#

class Season < ApplicationRecord
  belongs_to              :league
  has_many                :matches
  has_and_belongs_to_many :teams

  scope :current, -> () { where(current: true) }
end
