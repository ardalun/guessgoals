class Api::PlaysController < ApiController
  before_action :require_auth, only: [:create, :get_match_plays]
  
  RECORDS_PER_PAGE = 10

  def create
    match = Match.find_hash_by(id: params[:match_id])
    raise AppError::MatchNotFound if match.nil?

    if match.fetch(:starts_at, 1.day.ago) < DateTime.now || match.fetch(:pool_status, nil) != 'betting_open'
      raise AppError::PoolIsClosed
    end

    existing_play_ids = Play.where(match_id: params[:match_id], user_id: @current_user_id).pluck(:id)
    raise AppError::UserAlreadyPlayed if existing_play_ids.present?

    play = Play.create(play_params)
    raise AppError::InvalidRequest if !play.valid?

    resp_hash = { play: PlaySerializer.serialize(play) }
    render(status: 200, json: resp_hash)

  rescue AppError::InvalidRequest
    render(
      status: 422, 
      json: {
        error_code: 'validation_failed', 
        validation_errors: ValidationHelper.format_errors(play.errors.messages)
      }
    )
  rescue AppError::MatchNotFound
    render(status: 404, json: { error_code: 'match_not_found' })
  rescue AppError::PoolIsClosed
    render(status: 412, json: { error_code: 'pool_is_closed' })
  rescue AppError::UserAlreadyPlayed
    render(status: 412, json: { error_code: 'user_already_played' })
  end

  def get_match_plays
    match_id, match_pool_status = Match.where(id: params[:match_id]).pluck(:id, :pool_status).first
    raise AppError::MatchNotFound if match_id.nil?
    
    user_play_id = Play
      .where(user_id: @current_user_id, match_id: params[:match_id])
      .pluck(:id).first

    raise AppError::UserHasNotPlayedThisMatch if user_play_id.nil?

    if !['pending_outcome', 'finalized'].include?(match_pool_status)
      render(
        json: {
          plays:            [],
          current_page:     0,
          records_per_page: 0,
          total_records:    0
        },
        status: 200
      )
      return
    end

    all_plays = Play
      .where(match_id: params[:match_id])
      .where(payment_status: :accepted)
      .order(:rank)

    plays = all_plays
      .offset((params[:page].to_i - 1) * RECORDS_PER_PAGE)
      .limit(RECORDS_PER_PAGE)
      .serialize(PlaySerializer)
    
    user_ids = plays.pluck(:user_id)
    users_indexed = User.where(id: user_ids).quick_indexed_serialize([:id, :username], :id)

    plays.each do |play|
      play[:username] = users_indexed[play[:user_id]][:username]
    end

    render(
      json: {
        plays:            plays,
        current_page:     params[:page].to_i,
        records_per_page: RECORDS_PER_PAGE,
        total_records:    all_plays.count 
      },
      status: 200
    )
  rescue AppError::MatchNotFound
    render(status: 404, json: { error_code: 'match_not_found' })
  rescue AppError::UserHasNotPlayedThisMatch
    render(status: 412, json: { error_code: 'user_has_not_played_this_match' })
  end

  private

  def play_params
    permitted_params = params.permit(
      :winner_team,
      :away_score,
      :home_score,
      { away_scorers: [:id, :name] },
      { home_scorers: [:id, :name] },
      { team_goals: [] },
      :match_id
    )
    return permitted_params.merge( user_id: @current_user_id )
  end
end