# == Schema Information
#
# Table name: plays
#
#  id                     :bigint(8)        not null, primary key
#  away_score             :integer          default(0)
#  away_scorers           :jsonb
#  correct_scorers        :integer
#  correct_team_goals     :integer
#  goals_off              :integer
#  home_score             :integer          default(0)
#  home_scorers           :jsonb
#  payment_status         :integer          default("temp_accepted")
#  rank                   :integer
#  team_goals             :jsonb
#  winner_team            :integer          default("draw")
#  winner_team_is_correct :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  ledger_entry_id        :integer
#  match_id               :integer
#  user_id                :integer
#
# Indexes
#
#  index_plays_on_ledger_entry_id  (ledger_entry_id)
#  index_plays_on_match_id         (match_id)
#  index_plays_on_user_id          (user_id)
#

class PlaySerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :winner_team,
    :home_score,
    :away_score,
    :home_scorers,
    :away_scorers,
    :team_goals,
    :rank,
    :winner_team_is_correct,
    :goals_off,
    :correct_scorers,
    :correct_team_goals,
    :payment_status,
    :match_id,
    :user_id
  ]
end
