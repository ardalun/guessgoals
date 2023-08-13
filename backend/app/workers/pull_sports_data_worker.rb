class PullSportsDataWorker
  include Sidekiq::Worker

  def perform
    Sportmonks.pull_seasons
    Sportmonks.pull_teams
    Sportmonks.pull_players
    Sportmonks.pull_matches
  end
end
