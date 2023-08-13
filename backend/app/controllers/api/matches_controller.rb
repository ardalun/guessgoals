class Api::MatchesController < ApiController
  before_action :require_auth, only: [:played_matches]
  
  RECORDS_PER_PAGE = 10

  def index
    if params[:league_handle] == 'all'
      league_ids = League.enabled.pluck(:id)
    else
      league_ids = League.enabled.where(handle: params[:league_handle]).pluck(:id)
    end

    target_matches = Match.upcoming.where(league_id: league_ids)

    if params[:league_handle] == 'all'
      target_matches = target_matches.order(:hotness_rank).limit(15)
    end

    matches_indexed = target_matches.indexed_serialize(MatchSerializer)
    if @current_user_id.present?
      user_plays = Play.where(user_id: @current_user_id, match_id: matches_indexed.keys)
      user_plays_serialized = user_plays.serialize(PlaySerializer)
      user_plays_serialized.each do |play|
        matches_indexed[play[:match_id]][:play] = play
      end
    end
    
    render(status: 200, json: { matches: matches_indexed })
  end

  def show
    match = Match.where(id: params[:id]).limit(1).serialize(MatchSerializer).first

    if match.nil?
      render(status: 404, json: { error_code: 'match_not_found' }) and return
    end

    teams_data = Team
      .where(id: [match[:home_team]['id'], match[:away_team]['id']])
      .quick_indexed_serialize([:id, :formation, :formation_players], :id)

    match.merge!(
      home_formation: teams_data[match[:home_team]['id']][:formation],
      home_formation_players: teams_data[match[:home_team]['id']][:formation_players],
      away_formation: teams_data[match[:away_team]['id']][:formation],
      away_formation_players: teams_data[match[:away_team]['id']][:formation_players],
    )
    render(status: 200, json: { match: match })
  end

  def played_matches
    all_plays = Play
      .joins(:match)
      .where(user_id: @current_user_id)
      .order('matches.starts_at' => :desc)

    plays = all_plays
      .offset((params[:page].to_i - 1) * RECORDS_PER_PAGE)
      .limit(RECORDS_PER_PAGE)
      .serialize(PlaySerializer)
    
    match_ids = plays.pluck(:match_id)
    matches_indexed = Match.where(id: match_ids).indexed_serialize(MatchSerializer)

    plays.each do |play|
      matches_indexed[play[:match_id]][:play] = play
    end

    render(
      json: {
        matches: matches_indexed,
        current_page: params[:page].to_i,
        records_per_page: RECORDS_PER_PAGE,
        total_records: all_plays.count 
      },
      status: 200
    )

  end

end
