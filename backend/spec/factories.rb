FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
    sequence(:email)    { |n| "user_#{n}@gmail.com" }
    password { 'abcdefghA1!' }
    active   { true }
  end

  factory :league do
    transient do
      seasons_count      { 0 }
      teams_per_season   { 0 }
      players_per_team   { 0 }
      matches_per_season { 0 }
    end

    sequence(:sm_id)    { |n| "factory_league_#{n}" }
    sequence(:name)     { |n| "Factory League #{n}" }
    sequence(:handle)   { |n| "factory-league-#{n}" }
    sequence(:logo_url) { |n| "league_logos/factory-league-#{n}.svg" }
    active              { false }
    
    after(:create) do |league, evaluator|
      next if evaluator.seasons_count == 0
      (evaluator.seasons_count - 1).times do 
        create(:season, league_id: league.id)
      end
      current_season = create(:season, league_id: league.id, current: true)
      league.update!(season: current_season)
      prize_rule = create :prize_rule
      league.seasons.each do |season|
        evaluator.teams_per_season.times do
          team = create(:team)
          evaluator.players_per_team.times do |i|
            player = create(
              :player,
              team_id: team.id,
              number: i + 1
            )
          end
          season.teams << team
        end
        next if evaluator.teams_per_season < 2 
        evaluator.matches_per_season.times do
          team_ids = season.teams.ids.shuffle
          home_team_id = team_ids.pop
          away_team_id = team_ids.pop
          match  = create(
            :match, 
            league:       league, 
            season:       season, 
            home_team_id: home_team_id, 
            away_team_id: away_team_id, 
            prize_rule:   prize_rule
          )
        end
      end
    end

  end

  factory :season do
    sequence(:sm_id) { |n| "factory_season_#{n}" }
    year    { 2.years.ago.year }
    stage   { 'Regular Season' }
    current { false }
  end

  factory :team do
    sequence(:sm_id)      { |n| "factory_team_#{n}" }
    sequence(:code)       { |n| "CD#{n}" }
    sequence(:name)       { |n| "Fac Team #{n}" }
    sequence(:handle)     { |n| "ft#{n}-handle" }
    logo_url              { "#{API_URL}/team.png" }
    sequence(:rank)
  end

  factory :match do
    sequence(:sm_id) { |n| "factory_match_#{n}" }
    starts_at   { rand(1..1000).hours.from_now }
    stadium     { 'Test Arena' }
    status      { :not_started }
    pool_status { :betting_open }
    ticket_fee  { 0.001 }
    home_score  { 0 }
    away_score  { 0 }
    pool_size   { 0 }

    callback(:after_build, :before_create) do |match, evaluator|
      match.league_id    = create(:league).id if match.league_id.nil?
      match.home_team_id = create(:team).id if match.home_team_id.nil?
      match.away_team_id = create(:team).id if match.away_team_id.nil?
      match.prize_rule_id = create(:prize_rule).id if match.prize_rule_id.nil?
    end
  end

  factory :player do
    sequence(:sm_id)     { |n| "factory_player_#{n}" }
    sequence(:name)      { |n| "Factory Player #{n}" }
    number               { rand(1..15) }
    sequence(:position)  { |n| n % 11 == 1 ? :goalkeeper : n % 11 < 6 ? :defender : n % 11 < 10 ? :midfielder : :attacker  }
    goals_per_min        { rand(0..100) / 10000.0 }
    sequence(:image_url) { |n| "https://link.com/factory-player-#{n}.png" }
  end

  factory :prize_rule do
    sequence(:name) { |n| "name_#{n}" }
    rules           { {0..2 => 1.0, 3..3 => 0.83333, 4..1000000000 => 0.7} }
    active          { true }
  end

  factory :wallet do 
    total     { 0 }
    confirmed { 0 }
    locked    { 0 }
    is_master { false }
  end

  factory :ledger_entry do
    transient do
      with_wallet { true }
    end

    kind        { :ticket_payment }
    status      { :is_confirmed }
    total       { 0 }
    confirmed   { 0 }
    locked      { 0 }
    acceptable  { true }
    description { 0 }

    callback(:after_build, :before_create) do |ledger_entry, evaluator|
      ledger_entry.wallet_id = create(:wallet).id if ledger_entry.wallet_id.nil? && evaluator.with_wallet
    end
  end

  factory :play do
    winner_team     { :draw }
    home_score      { 0 }
    away_score      { 0 }
    home_scorers    { [] }
    away_scorers    { [] }
    team_goals      { [] }
    payment_status  { :temp_accepted }

    callback(:after_build, :before_create) do |play, evaluator|
      play.user_id  = create(:user).id if play.user.nil?
      play.match_id = create(:match).id if play.match.nil?
    end
  end

  factory :transfer do
    amount          { 0 }
    confirmations   { 0 }
    details         { [] }
    fee             { 0 }
    performed_at    { DateTime.now }
    txid            { SecureRandom.hex(20) }
  end

  factory :address do
    code       { SecureRandom.hex(10) }
    internal   { true }
    used       { false }
    wallet_id  { 0 }
    
    callback(:after_build, :before_create) do |address, evaluator|
      address.wallet_id = create(:wallet).id if address.wallet.nil?
    end
  end
  
  factory :notif do
    data { {} }
    kind { :funds_received }
    seen { false }

    callback(:after_build, :before_create) do |notif, evaluator|
      notif.user_id = create(:user).id if notif.user.nil?
    end
  end
end