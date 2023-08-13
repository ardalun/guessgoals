class NotifyMatchStartedWorker
  include Sidekiq::Worker

  def perform(play_id)
    user_id, match_id = Play
      .where(id: play_id)
      .pluck(:user_id, :match_id)
      .last
    
    home_team, away_team, real_prize, real_chance = Match
      .where(id: match_id)
      .pluck(:_home_team, :_away_team, :real_prize, :real_chance)
      .last
    
    Notif.create!({
      user_id: user_id,
      kind: :match_started,
      data: {
        play_id:     play_id,
        match_name:  "#{home_team['name']} vs #{away_team['name']}",
        real_chance: real_chance,
        real_prize:  real_prize
      }
    })
  end
end