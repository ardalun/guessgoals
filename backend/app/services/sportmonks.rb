class Sportmonks
  
  API_KEY = "QCU5NnhY86HmrM4xDX5cOitsT2uJltdhVVBIDp5eAfBBi5c8J84BzEpu9otG"
  
  def self.to_gg_status(sm_status)
    map = {
      'NS'       => :not_started, 
      'LIVE'     => :in_progress,
      'HT'       => :in_progress,
      'FT'       => :finished,
      'ET'       => :in_progress,
      'PEN_LIVE' => :finished,
      'AET'      => :finished,
      'BREAK'    => :in_progress,
      'FT_PEN'   => :finished,
      'CANCL'    => :unknown,
      'POSTP'    => :unknown,
      'INT'      => :unknown,
      'ABAN'     => :unknown,
      'SUSP'     => :unknown,
      'AWARDED'  => :unknown,
      'DELAYED'  => :unknown,
      'TBA'      => :unknown,
      'WO'       => :unknown,
      'AU'       => :unknown,
      'Deleted'  => :unknown,
      ''         => :unknown
    }
    return map.fetch(sm_status, :unknown)
  end

  def self.stage_enabled?(stage) 
    [
      "Regular Season",
      "Group Stage",
      "8th Finals",
      "Quarter-finals",
      "Semi-finals",
      "Final"
    ].include?(stage) ? true : false
  end
  
  # Run this function on demand yearly or when sportmonks plan changes
  def self.pull_leagues
    url = "https://soccer.sportmonks.com/api/v2.0/leagues?include=season&api_token=#{API_KEY}"
    leagues_array = self.request(url)
    leagues_array.each do |league_hash|
      league = League.find_or_initialize_by(sm_id: league_hash.fetch('id', nil))
      name   = league_hash.fetch('name', nil)
      if !Rails.env.test?
        print "#{name}? [Enter = Activate / n = Don't Activate]: "
        response = STDIN.gets.chomp
        active = response != 'n'
        next if league.persisted? && league.active == active
      end
      league.assign_attributes(
        name:     name,
        handle:   to_handle(name),
        logo_url: "league_logos/#{to_handle(name)}.svg",
        active:   active
      )
      league.save!
    end
  end

  # Run after leagues are pulled
  # Meant to run DAILY
  # Pulls seasons for all leagues syncs current stage
  def self.pull_seasons
    map_smid_to_league_id = {}
    League.pluck(:id, :sm_id).each { |arr| map_smid_to_league_id[arr.last] = arr.first }
    url = "https://soccer.sportmonks.com/api/v2.0/seasons?include=stages&api_token=#{API_KEY}"
    seasons_array = self.request(url)
    seasons_array.each do |season_hash|
      league_id = season_hash.fetch('league_id', nil).to_s
      next if !map_smid_to_league_id.key?(league_id)
      league_id = map_smid_to_league_id[league_id]
      stage_id  = season_hash.fetch('current_stage_id', nil)
      if stage_id.present?
        stage = season_hash.fetch('stages', {}).fetch('data', [])
          .select { |stage| stage.fetch('id', nil) == stage_id}
          .map { |stage| stage.fetch('name', nil)}
          .first
      end
      current   = season_hash.fetch('is_current_season', false)
      season    = Season.find_or_initialize_by(sm_id: season_hash.fetch('id', nil), league_id: league_id)
      season.assign_attributes(
        year:    season_hash.fetch('name', '').split('/').first,
        current: current,
        stage:   stage
      )
      Db.atomically do 
        season.save!
        if current
          league = League.find_by(id: league_id)
          if league.season_id != season.id
            league.season&.update!(current: false)
            league.update!(season_id: season.id)
          end
        end
      end
    end
  end

  # Meant to run DAILY after seasons are pulled
  # pulls teams of current seasons
  # update team ranks
  def self.pull_teams
    teams_json = JSON.parse(File.open("#{Rails.root}/db/teams.json").read)
    teams_data = {}
    teams_json.each do |team_json|
      teams_data[team_json.fetch('id', nil)] = team_json
    end
    Season.current.find_each do |season|
      url = "https://soccer.sportmonks.com/api/v2.0/teams/season/#{season.sm_id}?include=uefaranking,fifaranking&api_token=#{API_KEY}"
      teams_array = self.request(url)
      teams_array.each.with_index do |team_hash, i|
        sm_id = team_hash.fetch('id', '').to_s
        uefaranking = team_hash.fetch('uefaranking', {}).fetch('data', {}).fetch('position', nil)
        fifaranking = team_hash.fetch('fifaranking', {}).fetch('data', {}).fetch('position', nil)
        rank = uefaranking || fifaranking || 1000
        team = Team.find_by(sm_id: sm_id)
        if team.nil?
          if teams_data.include?(sm_id)
            name       = teams_data[sm_id]['name']
            short_name = teams_data[sm_id]['short_name']
          else
            name       = team_hash.fetch('name', nil)
            short_name = name
          end
          short_name = name if short_name.empty?
          team = Team.create!(
            sm_id:    sm_id,
            name:     short_name,
            code:     team_hash.fetch('short_code', nil),
            rank:     rank,
            handle:   to_handle(short_name),
            logo_url: team_hash.fetch('logo_path', nil)
          )
        elsif team.rank != rank
          team.update!(rank: rank)
        end
        season.teams << team if !season.teams.include?(team)
      end
    end
  end

  # Meant to run DAILY after teams are pulled
  # pulls latest players of each team
  def self.pull_players
    Team.find_each do |team|
      url = "https://soccer.sportmonks.com/api/v2.0/teams/#{team.sm_id}?include=squad.player.stats,squad.player.team,squad.player.position&api_token=#{API_KEY}"
      team_hash = self.request(url)
      team_hash.fetch('squad', {}).fetch('data', []).each do |player_root_hash|
        player_hash    = player_root_hash.fetch('player', {}).fetch('data', {})
        player_sm_id   = player_hash.fetch('player_id', nil)
        player_team_id = player_hash.fetch('team', {}).fetch('data', {}).fetch('id', nil)
        next if player_sm_id.nil?
        next if !player_team_id.nil? && player_team_id.to_i != team.sm_id.to_i
        stats    = player_hash.fetch('stats', {}).fetch('data', [])
        goals    = stats.sum { |stat| stat.fetch('goals', 0) }.to_f
        minutes  = stats.sum { |stat| stat.fetch('minutes', 0) }.to_f
        position = player_hash.fetch('position', {}).fetch('data', {}).fetch('name', nil).to_s.downcase
        next if Player.positions.keys.exclude?(position)
        player   = Player.find_or_initialize_by(sm_id: player_sm_id)
        player.assign_attributes(
          name:          player_hash.fetch('fullname', nil).to_s.unicode_normalize(:nfc),
          position:      position,
          image_url:     player_hash.fetch('image_path', nil),
          number:        player_root_hash.fetch('number', nil),
          goals_per_min: minutes != 0 ? (goals / minutes).round(8) : 0,
          team_id:       player_team_id.nil? ? nil : team.id
        )
        player.save!
      end
    end
  end


  # Meant to run DAILY after teams are pulled
  # pulls upcoming matches (up to 1 month from now), creates or update status & time
  def self.pull_matches
    active_prize_rule = PrizeRule.current
    raise AppError::NoActivePrizeRuleIsFound if active_prize_rule.nil?

    map_smid_to_league_id = {}
    map_smid_to_team_id = {}
    map_smid_to_season_id = {}

    League.pluck(:id, :sm_id).each { |arr| map_smid_to_league_id[arr.last] = arr.first }
    Season.pluck(:id, :sm_id).each { |arr| map_smid_to_season_id[arr.last] = arr.first }
    Team.pluck(:id, :sm_id).each   { |arr| map_smid_to_team_id[arr.last]   = arr.first }

    today_utc            = DateTime.now.utc.to_date
    a_month_from_now_utc = today_utc + 30.days
    url = "https://soccer.sportmonks.com/api/v2.0/fixtures/between/#{today_utc}/#{a_month_from_now_utc}?include=stage,venue&api_token=#{API_KEY}"
    fixtures = self.request(url)
    fixtures.each do |fixture|
      status       = to_gg_status(fixture.fetch('time', {}).fetch('status', nil))
      pool_status  = status == :not_started ? :betting_open : :betting_closed
      stage        = fixture.fetch('stage', {}).fetch('data', {}).fetch('name', nil)
      home_team_id = map_smid_to_team_id.fetch(fixture.fetch('localteam_id', nil).to_s, nil)
      away_team_id = map_smid_to_team_id.fetch(fixture.fetch('visitorteam_id', nil).to_s, nil)
      season_id    = map_smid_to_season_id.fetch(fixture.fetch('season_id', 0).to_s, nil)
      league_id    = map_smid_to_league_id.fetch(fixture.fetch('league_id', 0).to_s, nil)
      timestamp    = fixture.fetch('time', {}).fetch('starting_at', {}).fetch('timestamp', nil).to_s
      
      next if !stage_enabled?(stage)
      next if home_team_id.nil? || away_team_id.nil? || season_id.nil? || league_id.nil?

      match = Match.find_by(sm_id: fixture.fetch('id', nil))
      if match.nil?
        next if active_prize_rule.nil?
        Match.create!(
          sm_id:        fixture.fetch('id', nil),
          starts_at:    DateTime.strptime(timestamp, '%s'),
          stadium:      fixture.fetch('venue', {}).fetch('data', {}).fetch('name', nil),
          status:       status,
          pool_status:  pool_status,
          home_team_id: home_team_id,
          away_team_id: away_team_id,
          season_id:    season_id,
          league_id:    league_id,
          prize_rule:   active_prize_rule,
          ticket_fee:   Rules::TICKET_FEE
        )
      else
        match.update!(
          starts_at:   DateTime.strptime(timestamp, '%s'),
          status:      status,
          pool_status: pool_status,
        )
      end
    end
    return nil
  end

  # Meant to run pull latest status and stats of a match
  # Sample fixture_sm_id 10330201
  def self.pull_match(match)
    url         = "https://soccer.sportmonks.com/api/v2.0/fixtures/#{match.sm_id}?include=goals&api_token=#{API_KEY}"
    match_hash  = self.request(url)
    goals       = match_hash.fetch('goals', {}).fetch('data',[])
    goals.map! do |g|
      {
        minute:       g.fetch('minute', nil).to_i,
        extra_minute: g.fetch('extra_minute', nil),
        team:         g.fetch('team_id', nil) == match.home_team.sm_id ? 'home' : 'away',
        player_sm_id: g.fetch('player_id', nil),
        player_name:  g.fetch('player_name', nil).to_s.unicode_normalize(:nfc)
      }
    end
    goals.sort_by! { |g| g[:minute] + g[:extra_minute].to_i }
    new_status = to_gg_status(match_hash.fetch('time', {}).fetch('status', ''))
    match.update!(
      status:     new_status,
      home_score: goals.select { |e| e[:team] == 'home' }.count,
      away_score: goals.select { |e| e[:team] == 'away' }.count,
      goals:      goals
    )
  end

  # Pulls the latest formation of home and away teams of a match
  # is needed for viewing players on their most recent pitch positions
  # Meant to run only one time after match is finished
  def self.pull_formations(match_id)
    match       = Match.find_by(id: match_id)
    return if match.nil?
    url         = "https://soccer.sportmonks.com/api/v2.0/fixtures/#{match.sm_id}?include=lineup,bench&api_token=#{API_KEY}"
    match_hash  = self.request(url)
    home_formation = match_hash.fetch('formations', {}).fetch('localteam_formation', nil)
    away_formation = match_hash.fetch('formations', {}).fetch('visitorteam_formation', nil)
    return if home_formation.blank? || away_formation.blank?
    
    Db.atomically do
      match.update!(formation_synced: true)
      players_array = match_hash.fetch('lineup', {}).fetch('data', []) + match_hash.fetch('bench', {}).fetch('data', [])
      players_array.sort_by! do |item| 
        pos = item.fetch('formation_position', nil)
        if !pos.nil? && pos > 0 && pos < 12
          next pos
        else
          next 12
        end
      end
      players_relation = Player.where(sm_id: players_array.pluck('player_id'))
      player_sm_id_map = players_relation.quick_indexed_serialize([:id, :sm_id], :sm_id)
      indexed_players  = players_relation.indexed_serialize(PlayerSerializer)
      home_formation_players = []
      away_formation_players = []
      players_array.each do |player|
        player_sm_id = player.fetch('player_id', nil)
        player_id    = player_sm_id_map.fetch(player_sm_id.to_s, {}).fetch(:id, nil)
        next if player_id.nil?
        if player.fetch('team_id', nil).to_s == match.home_team.sm_id
          home_formation_players << indexed_players[player_id]
        elsif player.fetch('team_id', nil).to_s == match.away_team.sm_id
          away_formation_players << indexed_players[player_id]
        end
      end
      match.home_team.update!(formation: home_formation, formation_players: home_formation_players)
      match.away_team.update!(formation: away_formation, formation_players: away_formation_players)
    end
  end

  # Pulls video highlight links for a match
  # Meant to run 1hr after match is finished
  def self.pull_highlights(match_id)
    match       = Match.find_by(id: match_id)
    return if match.nil?
    url         = "https://soccer.sportmonks.com/api/v2.0/fixtures/#{match.sm_id}?include=highlights&api_token=#{API_KEY}"
    match_hash  = self.request(url)
    highlight_links = match_hash
      .fetch('highlights', {})
      .fetch('data', [])
      .select { |hash| ['video', 'clip'].include?(hash.fetch('type', nil)) }
      .pluck('location')
    
    Db.atomically do
      match.update!(highlights_synced: true)
      highlight_links.each do |highlight_link|
        Highlight.create!(
          original_link: highlight_link,
          match_id: match_id
        )
      end
    end
  end

  def self.request(url)
    resp = JSON.try(:parse, (HTTParty.get(url).response.body))
    pages = resp.fetch('meta', {}).fetch('pagination', {}).fetch('total_pages', '1').to_i
    result = resp.fetch('data', [])
    (pages - 1).times do |p|
      page_url = url + "&page=#{p + 2}"
      result += JSON.try(:parse, (HTTParty.get(page_url).response.body)).fetch('data', [])
    end
    return result
  end

  def self.test
    while true
      url  = "https://soccer.sportmonks.com/api/v2.0/leagues?include=seasons&api_token=#{API_KEY}"
      resp = self.request(url)
      puts resp
    end
  end

  private

  def self.to_handle(name)
    name
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1-\2')
      .gsub(/([a-z\d])([A-Z])/,'\1-\2')
      .gsub(/\s/, '-')
      .gsub(/__+/, '-')
      .downcase
      .unicode_normalize(:nfc)
  end
end