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

class League < ApplicationRecord
  belongs_to :season
  has_many :seasons
  has_many :matches

  scope :enabled, -> { where(active: true) }
end
