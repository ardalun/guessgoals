# == Schema Information
#
# Table name: matches
#
#  id                      :bigint(8)        not null, primary key
#  _away_team              :jsonb
#  _home_team              :jsonb
#  _league                 :jsonb
#  away_score              :integer          default(0)
#  check_started_scheduled :boolean          default(FALSE)
#  estimated_chance        :float            default(0.0)
#  estimated_prize         :float            default(0.0)
#  formation_synced        :boolean          default(FALSE)
#  goals                   :jsonb
#  highlights_synced       :boolean          default(FALSE)
#  home_score              :integer          default(0)
#  hotness_rank            :integer          default(10000)
#  pool_size               :integer          default(0)
#  pool_status             :integer          default("betting_closed")
#  prize_share             :float            default(0.0)
#  pushed_to_social_media  :boolean          default(FALSE)
#  real_chance             :float            default(0.0)
#  real_prize              :float            default(0.0)
#  stadium                 :string
#  starts_at               :datetime
#  status                  :integer          default("not_started")
#  ticket_fee              :float            default(0.0)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  away_team_id            :integer
#  home_team_id            :integer
#  league_id               :integer
#  prize_rule_id           :integer
#  season_id               :integer
#  sm_id                   :string
#
# Indexes
#
#  index_matches_on_away_team_id   (away_team_id)
#  index_matches_on_home_team_id   (home_team_id)
#  index_matches_on_league_id      (league_id)
#  index_matches_on_prize_rule_id  (prize_rule_id)
#  index_matches_on_season_id      (season_id)
#

class MatchSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :_league,
    :_home_team,
    :_away_team,
    :starts_at,
    :stadium,
    :pool_status,
    :estimated_chance,
    :real_chance,
    :estimated_prize,
    :real_prize,
    :ticket_fee,
    :home_score,
    :away_score,
    :goals
  ]

  def self.make_hash(raw_array)
    data = super(raw_array)
    data[:league]    = data.delete(:_league)
    data[:home_team] = data.delete(:_home_team)
    data[:away_team] = data.delete(:_away_team)
    data[:ticket_fee_usd]      = data[:ticket_fee] * 10000.0
    data[:estimated_prize_usd] = data[:estimated_prize] * 10000.0
    data[:home_goals] = data[:goals].select { |e| e['team'] == 'home' }.sort_by { |e| e['minute'] }
    data[:away_goals] = data[:goals].select { |e| e['team'] == 'away' }.sort_by { |e| e['minute'] }
    data.delete(:goals)
    return data
  end
end
