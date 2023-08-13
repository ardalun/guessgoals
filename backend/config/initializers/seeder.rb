def image_adr(name)
  ActionController::Base.helpers.image_path(name) rescue nil
end

def font_adr(name)
  ActionController::Base.helpers.font_path(name) rescue nil
end

def purge
  return if Rails.env.production?

  Sidekiq::Queue.new.clear
  Sidekiq::DeadSet.new.clear
  Sidekiq::ScheduledSet.new.clear
  Sidekiq::RetrySet.new.clear

  Address.destroy_all
  League.destroy_all
  LedgerEntry.destroy_all
  Match.destroy_all
  Notif.destroy_all
  Play.destroy_all
  Player.destroy_all
  PrizeRule.destroy_all
  Refund.destroy_all
  Season.destroy_all
  Team.destroy_all
  Transfer.destroy_all
  User.destroy_all
  Wallet.destroy_all
  PrizeRule.destroy_all
  
  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end
  
  User.create!(
    username: 'meysam',
    email:    'me.feghhi@gmail.com',
    password: 'B00ghB00gh1!',
    active:   true,
    admin: true
  )

end

def clean_all
  return if Rails.env.production?

  Sidekiq::Queue.new.clear
  Sidekiq::DeadSet.new.clear
  Sidekiq::ScheduledSet.new.clear
  Sidekiq::RetrySet.new.clear
  
  Address.destroy_all
  League.destroy_all
  LedgerEntry.destroy_all
  Match.destroy_all
  Notif.destroy_all
  Play.destroy_all
  Player.destroy_all
  PrizeRule.destroy_all
  Refund.destroy_all
  Season.destroy_all
  Team.destroy_all
  Transfer.destroy_all
  User.destroy_all
  Wallet.destroy_all
  
  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end
  
  User.create!(
    username: 'meysam',
    email:    'me.feghhi@gmail.com',
    password: 'B00ghB00gh1!',
    active:   true,
    admin: true
  )
  leagues = [
    {
      sm_id:      2,
      name:       'Champions League',
      handle:     'champions-league',
      logo_url:   'league_logos/champions-league.svg',
      sort_order: 1
    },
    {
      sm_id:      8,
      name:       'Premier League',
      handle:     'premier-league',
      logo_url:   'league_logos/premier-league.svg',
      sort_order: 2
    },
    {
      sm_id:      564,
      name:       'La Liga',
      handle:     'la-liga',
      logo_url:   'league_logos/la-liga.svg',
      sort_order: 3
    },
    {
      sm_id:      82,
      name:       'Bundesliga',
      handle:     'bundesliga',
      logo_url:   'league_logos/bundesliga.svg',
      sort_order: 4
    },
    {
      sm_id:      384,
      name:       'Serie A',
      handle:     'serie-a',
      logo_url:   'league_logos/serie-a.svg',
      sort_order: 5
    },
    {
      sm_id:      301,
      name:       'Ligue 1',
      handle:     'ligue-1',
      logo_url:   'league_logos/ligue-1.svg',
      sort_order: 6
    }
  ]

  leagues.each do |league|
    FactoryBot.create(
      :league,
      sm_id: league[:sm_id],
      name: league[:name],
      handle: league[:handle],
      logo_url: league[:logo_url],
      active: true,
      seasons_count: 1,
      teams_per_season: 4, 
      players_per_team: 18,
      matches_per_season: 5
    )
  end
  Team.find_each do |team|
    team.update!(formation: ['4-4-2', '4-3-3', '3-5-2', '5-3-2', '4-3-1-2'].sample)
    team.seed_formation
  end
end

def clean
  return if Rails.env.production?

  Sidekiq::Queue.new.clear
  Sidekiq::DeadSet.new.clear
  Sidekiq::ScheduledSet.new.clear
  Sidekiq::RetrySet.new.clear

  Address.destroy_all
  LedgerEntry.destroy_all
  Notif.destroy_all
  Play.destroy_all
  Refund.destroy_all
  Transfer.destroy_all
  User.destroy_all
  Wallet.where(owner_type: 'User').destroy_all
  Wallet.update_all(total: 0, confirmed: 0, locked: 0)
  Match.update_all(
    status: :not_started, 
    pool_status: :betting_open, 
    estimated_chance: 50, 
    real_chance: 0, 
    estimated_prize: 0.002, 
    real_prize: 0, 
    pool_size: 0
  )

  ActiveRecord::Base.connection.reset_pk_sequence!('users')
  User.create!(
    username: 'meysam',
    email:    'me.feghhi@gmail.com',
    password: 'B00ghB00gh1!',
    active:   true,
    admin: true
  )
end

def _seed
  if PrizeRule.current.nil?
    PrizeRule.create!(
      active: true,
      name: 'one',
      rules: {
        0..2 => 1.0,
        3..3 => 0.83333, 
        4..1000000000 => 0.7
      }
    )
  end

  Sportmonks.pull_leagues
  Sportmonks.pull_seasons
  Sportmonks.pull_teams
  Sportmonks.pull_matches
  Sportmonks.pull_players

  Team.find_each do |team|
    team.seed_formation
  end
end
