require 'rails_helper'

RSpec.describe Api::PlaysController, type: :controller do

  describe ".create => POST /matches/:match_id/plays" do
    it "returns 403 if user is not authenticated" do
      post :create, params: { match_id: 1 }
      expect(response).to have_http_status(403)
    end

    it "returns 404 if match is not found" do
      user = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post :create, params: { match_id: 1 }
      expect(response).to have_http_status(404)
    end

    it "returns 404 if match is not found" do
      user = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post :create, params: { match_id: 1 }
      expect(response).to have_http_status(404)
    end

    it "returns 412 if pool is betting_closed" do
      user = create(:user)
      match = create(:match, pool_status: :betting_closed)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post :create, params: { match_id: match.id }
      expect(response).to have_http_status(412)
    end

    it "returns 412 if pool is pending_outcome" do
      user = create(:user)
      match = create(:match, pool_status: :pending_outcome)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post :create, params: { match_id: match.id }
      expect(response).to have_http_status(412)
    end

    it "returns 412 if pool is completed" do
      user = create(:user)
      match = create(:match, pool_status: :finalized)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post :create, params: { match_id: match.id }
      expect(response).to have_http_status(412)
    end

    it "returns 412 if match starts_at is in the past" do
      user = create(:user)
      match = create(:match, pool_status: :betting_open, starts_at: 1.minute.ago)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post :create, params: { match_id: match.id }
      expect(response).to have_http_status(412)
    end

    it "returns 412 if user already played" do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 5
      match  = league.season.matches.first
      match.update!(ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      play = create(:play, user: user, match: match)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post :create, params: { match_id: match.id }
      expect(response).to have_http_status(412)
    end

    it "returns 422 if play is invalid" do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 5
      match  = league.season.matches.first
      match.update!(ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post(
        :create, 
        params: { 
          match_id: match.id,
          winner_team: 'home',
          home_score: 1,
          away_score: 0,
          home_scorers: [],
          away_scorers: [],
          team_goals: ['home']
        }
      )
      expect(response).to have_http_status(422)
    end

    it "creates play if everything is fine" do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 5
      match  = league.season.matches.first
      match.update!(ticket_fee: 0.001)
      user = create(:user)
      user.wallet.update!(total: 0.001, confirmed: 0)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      post(
        :create, 
        params: { 
          match_id: match.id,
          winner_team: 'home',
          home_score: 1,
          away_score: 0,
          home_scorers: [
            {
              id: match.home_team.players.first.id,
              name: match.home_team.players.first.name,
            }
          ],
          away_scorers: [],
          team_goals: ['home']
        }
      )
      expect(response).to have_http_status(200)
    end
  end

end
