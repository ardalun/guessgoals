require 'rails_helper'

RSpec.describe 'Sportmonks Service', type: :service do

  describe '.pull_leagues' do
    it 'creates new leagues' do
      leagues_array = [
        {
          'id'   => 'league_1',
          'name' => 'Test League'
        }
      ]
      allow(Sportmonks).to receive(:request).and_return(leagues_array)
      Sportmonks.pull_leagues
      expect(League.count).to         eq(1)
      expect(League.last.sm_id).to    eq('league_1')
      expect(League.last.name).to     eq('Test League')
      expect(League.last.handle).to   eq('test-league')
      expect(League.last.logo_url).to eq('league_logos/test-league.svg')
      expect(League.last.active?).to  eq(false)
    end
  end
  

  describe '.pull_seasons' do
    it 'creates new seasons' do
      league = create(:league, seasons_count: 1)
      old_season = league.season
      seasons_array = [
        {
          'id'                => 'season_1',
          'name'              => '2019/2020',
          'league_id'         => league.sm_id,
          'current_stage_id'  => 'stage_1',
          'is_current_season' => true,
          'stages' => {
            'data' => [
              {
                'id'   => 'stage_1',
                'name' => 'Regular Season'
              }
            ]
          }
        }
      ]
      allow(Sportmonks).to receive(:request).and_return(seasons_array)
      
      Sportmonks.pull_seasons
      
      league.reload
      old_season.reload
      expect(Season.count).to           eq(2)
      expect(old_season.current?).to    be(false)
      expect(league.season.current?).to be(true)
      expect(league.season.sm_id).to    eq('season_1')
      expect(league.season.year).to     eq(2019)
      expect(league.season.stage).to    eq('Regular Season')
    end
  end
  
  describe '.pull_teams' do
    it 'creates new teams' do
      league = create :league, seasons_count: 1
      season = league.season
      teams_array = [
        {
          "id"         => 'team_1',
          "name"       => "Manchester United",
          "short_code" => "MUN",
          "logo_path"  => "https://link.com",
          "uefaranking" => {
            "data" => {
              "position" => 10
            }
          }
        }
      ]
  
      allow(Sportmonks).to receive(:request).and_return(teams_array)
      
      Sportmonks.pull_teams
      season.reload
  
      expect(season.teams.count).to   eq(1)
      expect(Team.last.sm_id).to      eq('team_1')
      expect(Team.last.name).to       eq('Manchester United')
      expect(Team.last.code).to       eq('MUN')
      expect(Team.last.logo_url).to   eq('https://link.com')
      expect(Team.last.rank).to       eq(10)
      expect(Team.last.handle).to     eq('manchester-united')
    end
  end
  

  describe '.pull_matches' do
    it 'creates non-existing matches' do
      create :prize_rule
      league = create :league, seasons_count: 1, teams_per_season: 2
      season = league.season
      home_team = season.teams.first
      away_team = season.teams.second
      start_time = 1.hour.from_now.change(:sec => 0)
      fixtures = [
        {
          "id"             => 'match_1',
          "league_id"      => league.sm_id,
          "season_id"      => season.sm_id,
          "localteam_id"   => home_team.sm_id,
          "visitorteam_id" => away_team.sm_id,
          "time" => {
            "status" => "NS",
            "starting_at" => {
              "timestamp" => start_time.to_i,
            },
            "minute" => nil,
            "extra_minute" => nil,
          },
          "stage" => {
            "data" => {
              "id"   => 7743307,
              "name" => "Regular Season"
            }
          }
        }
      ]
      allow(Sportmonks).to receive(:request).and_return(fixtures)
      
      Sportmonks.pull_matches
  
      season.reload
      expect(season.matches.count).to   eq(1)
      match = season.matches.first
      expect(match.not_started?).to     eq(true)
      expect(match.starts_at).to        eq(start_time)
      expect(match._home_team['handle']).to eq(home_team.handle)
      expect(match._away_team['handle']).to eq(away_team.handle)
      expect(match.goals).to            eq([])
      expect(match.home_score).to       eq(0)
      expect(match.away_score).to       eq(0)
      expect(match.real_prize).to       eq(0.0)
      expect(match._league['handle']).to    eq(season.league.handle)
    end

    it 'does not create non-existing matches if it is not in white-listed stages' do
      league = create :league, seasons_count: 1, teams_per_season: 2
      season = league.season
      home_team = season.teams.first
      away_team = season.teams.second
      start_time = 1.hour.from_now.change(:sec => 0)
      fixtures = [
        {
          "id"             => 'match_1',
          "league_id"      => league.sm_id,
          "season_id"      => season.sm_id,
          "localteam_id"   => home_team.sm_id,
          "visitorteam_id" => away_team.sm_id,
          "time" => {
            "status" => "NS",
            "starting_at" => {
              "timestamp" => start_time.to_i,
            },
            "minute" => nil,
            "extra_minute" => nil,
          },
          "stage" => {
            "data" => {
              "id"   => 7743307,
              "name" => "Unknown Stage"
            }
          }
        }
      ]
      allow(Sportmonks).to receive(:request).and_return(fixtures)
      
      Sportmonks.pull_matches
  
      season.reload
      expect(season.matches.count).to   eq(0)
    end

    it 'updates schedule of existing matches' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1
      season = league.season
      home_team = season.teams.first
      away_team = season.teams.second
      match  = season.matches.first
      start_time = 1.days.ago.change(:sec => 0)
      fixtures = [
        {
          "id"             => match.sm_id,
          "league_id"      => league.sm_id,
          "season_id"      => season.sm_id,
          "localteam_id"   => home_team.sm_id,
          "visitorteam_id" => away_team.sm_id,
          "time" => {
            "status" => "FT",
            "starting_at" => {
              "timestamp" => start_time.to_i,
            },
            "minute" => nil,
            "extra_minute" => nil,
          },
          "stage" => {
            "data" => {
              "id"   => 7743307,
              "name" => "Regular Season"
            }
          }
        }
      ]
      allow(Sportmonks).to receive(:request).and_return(fixtures)
      
      Sportmonks.pull_matches
  
      match.reload
      expect(Match.count).to        eq(1)
      expect(match.finished?).to    eq(true)
      expect(match.starts_at).to    eq(start_time)
      expect(match.hotness_rank).to eq(home_team.rank + away_team.rank)
    end
  end

  describe '.pull_players' do
    it 'creates new player for team' do 
      team = create :team
      team_hash = {
        "id"    => 12,
        "squad" => {
          "data" => [
            {
              "number" => 5,
              "player" => {
                "data" => {
                  "player_id"  => 'player_1',
                  "fullname"   => "C. Trueman",
                  "image_path" => "https//cdn.sportmonks.com/images/soccer/players/28/6140.png",
                  "team" => {
                    "data" => {
                      "id" => team.sm_id
                    }
                  },
                  "stats" => {
                    "data" => [
                      {
                        "minutes" => 5,
                        "goals"   => 10
                      }
                    ]
                  },
                  "position" => {
                    "data" => {
                      "id"   => 1,
                      "name" => "Goalkeeper"
                    }
                  }
                }
              }
            }
          ]
        }
      }
      allow(Sportmonks).to receive(:request).and_return(team_hash)
  
      Sportmonks.pull_players
      team.reload
  
      expect(team.players.count).to eq(1)
      player = team.players.first
      expect(player.sm_id).to              eq('player_1')
      expect(player.name).to               eq("C. Trueman")
      expect(player.goals_per_min).to      eq(2.0)
      expect(player.goalkeeper?).to        eq(true)
      expect(player.team.id).to            eq(team.id)
    end

    it 'transfers players between teams' do
      league = create :league, seasons_count: 1, teams_per_season: 2, players_per_team: 2
      season = league.season
      team_1 = season.teams.first
      team_2 = season.teams.second
      player = team_1.players.first
  
      team_1_hash = {
        "id"    => team_2.sm_id,
        "squad" => {
          "data" => [
            {
              "number" => 5,
              "player" => {
                "data" => {
                  "player_id"  => player.sm_id,
                  "fullname"   => "C. Trueman",
                  "image_path" => "https//cdn.sportmonks.com/images/soccer/players/28/6140.png",
                  "team" => {
                    "data" => {
                      "id" => team_2.sm_id
                    }
                  },
                  "position" => {
                    "data" => {
                      "name" => "Goalkeeper"
                    }
                  }
                }
              }
            }
          ]
        }
      }
  
      team_2_hash = {
        "id"    => team_2.sm_id,
        "squad" => {
          "data" => [
            {
              "number" => 5,
              "player" => {
                "data" => {
                  "player_id"  => player.sm_id,
                  "fullname"   => "C. Trueman",
                  "image_path" => "https//cdn.sportmonks.com/images/soccer/players/28/6140.png",
                  "team" => {
                    "data" => {
                      "id" => team_2.sm_id
                    }
                  },
                  "position" => {
                    "data" => {
                      "name" => "Goalkeeper"
                    }
                  }
                }
              }
            }
          ]
        }
      }
  
      team_1_url = "https://soccer.sportmonks.com/api/v2.0/teams/#{team_1.sm_id}?include=squad.player.stats,squad.player.team,squad.player.position&api_token=#{Sportmonks::API_KEY}"
      team_2_url = "https://soccer.sportmonks.com/api/v2.0/teams/#{team_2.sm_id}?include=squad.player.stats,squad.player.team,squad.player.position&api_token=#{Sportmonks::API_KEY}"
      
      allow(Sportmonks).to receive(:request).with(team_1_url).and_return(team_1_hash)
      allow(Sportmonks).to receive(:request).with(team_2_url).and_return(team_2_hash)
  
      Sportmonks.pull_players
      team_1.reload
      team_2.reload
      player.reload
  
      expect(team_1.players.count).to eq(1)
      expect(team_2.players.count).to eq(3)
      expect(player.team.id).to       eq(team_2.id)
    end

    it 'ends memberships' do 
      league = create :league, seasons_count: 1, teams_per_season: 1, players_per_team: 1
      team   = league.season.teams.first
      player = team.players.first
  
      team_hash = {
        "id"    => team.sm_id,
        "squad" => {
          "data" => [
            {
              "number" => 5,
              "player" => {
                "data" => {
                  "player_id"  => player.sm_id,
                  "fullname"   => "C. Trueman",
                  "image_path" => "https//cdn.sportmonks.com/images/soccer/players/28/6140.png",
                  "position" => {
                    "data" => {
                      "name" => "Goalkeeper"
                    }
                  }
                }
              }
            }
          ]
        }
      }
      allow(Sportmonks).to receive(:request).and_return(team_hash)
  
      Sportmonks.pull_players
      team.reload
      player.reload
  
      expect(team.players.count).to eq(0)
      expect(player.team).to        be(nil)
    end
  end

  
  describe '.pull_matches' do
    it 'creates matches' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1
      season = league.season
      match  = season.matches.first
      team_1 = match.home_team
      team_2 = match.away_team
      match_hash = {
        "id" => match.sm_id,
        "time" => {
          "status" => "LIVE",
          "starting_at" => {
            "timestamp" => 1.hour.ago.to_i
          }
        },
        "goals" => {
          "data" => [
            {
              "team_id"      => match.home_team.sm_id,
              "player_id"    => 10,
              "player_name"  => "Player Number 10",
              "minute"       => 8,
              "extra_minute" => nil
            },
            {
              "team_id"      => match.home_team.sm_id,
              "player_id"    => 12,
              "player_name"  => "Player Number 12",
              "minute"       => 28,
              "extra_minute" => nil
            }
          ]
        }
      }
  
      allow(Sportmonks).to receive(:request).and_return(match_hash)
  
      Sportmonks.pull_match(match)
  
      expect(match.in_progress?).to eq(true)
      expect(match.home_score).to eq(2)
      expect(match.away_score).to eq(0)
      expect(match.goals.size).to eq(2)
      expect(match.goals.first).to eq({
        "minute"=>8, 
        "extra_minute"=>nil, 
        "team"=>"home", 
        "player_sm_id"=>10, 
        "player_name"=>"Player Number 10"
      })
      expect(match.goals.second).to eq({
        "minute"=>28, 
        "extra_minute"=>nil, 
        "team"=>"home", 
        "player_sm_id"=>12, 
        "player_name"=>"Player Number 12"
      })
    end
  end

  describe '.pull_formation' do
    it 'pulls team formations' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      season = league.season
      match  = season.matches.first
      team_1 = match.home_team
      team_2 = match.away_team
      home_player = team_1.players.first
      away_player = team_2.players.first
  
      match_hash = {
        "id" => match.sm_id,
        "formations" => {
          "localteam_formation"   => "4-2-3-1",
          "visitorteam_formation" => "4-4-2"
        },
        "lineup" => {
          "data" => [
            {
              "team_id"            => team_1.sm_id,
              "player_id"          => home_player.sm_id,
              "formation_position" => 5
            }
          ]
        },
        "bench" => {
          "data" => [
            {
              "team_id"            => team_2.sm_id,
              "player_id"          => away_player.sm_id,
              "formation_position" => nil
            }
          ]
        }
      }
  
      allow(Sportmonks).to receive(:request).and_return(match_hash)
  
      Sportmonks.pull_formations(match.id)
  
      match.reload
      team_1.reload
      team_2.reload
      home_player.reload
      away_player.reload
  
      expect(match.formation_synced?).to        be(true)
      expect(team_1.formation).to               eq('4-2-3-1')
      expect(team_2.formation).to               eq('4-4-2')
      expect(team_1.formation_players.count).to eq(1)
      expect(team_1.formation_players.first['sm_id']).to eq(home_player.sm_id)
      expect(team_2.formation_players.count).to eq(1)
      expect(team_2.formation_players.first['sm_id']).to eq(away_player.sm_id)
    end
  end

  describe '.pull_highlights' do
    it 'pulls highlight clip and video links' do
      match = create :match
      match_hash = {
        "id" => match.sm_id,
        "highlights" => {
          "data" => [
            {
              "type" => "video",
              "location" => "http://link1.com"
            },
            {
              "type" => "clip",
              "location" => "http://link2.com"
            },
            {
              "type" => "photo",
              "location" => "http://link3.com"
            }
          ]
        }
      }
  
      allow(Sportmonks).to receive(:request).and_return(match_hash)
  
      Sportmonks.pull_highlights(match.id)
  
      match.reload
  
      expect(match.highlights_synced?).to            be(true)
      expect(match.highlights.count).to              eq(2)
      expect(Highlight.pluck(:original_link)).to     include("http://link1.com")
      expect(Highlight.pluck(:original_link)).to     include("http://link2.com")
      expect(Highlight.pluck(:original_link)).not_to include("http://link3.com")
    end
  end
end
