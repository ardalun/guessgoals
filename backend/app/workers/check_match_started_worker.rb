class CheckMatchStartedWorker
  include Sidekiq::Worker

  # This is when the match should have been started
  # Keep re-checking with a short wait until the match is actully started

  def perform(match_id)
    match = Match.find_by(id: match_id)
    already_started = match.in_progress? || match.finished?
    raise AppError::MatchAlreadyStarted if already_started
    
    Db.atomically do
      match.update!(pool_status: :betting_closed)
      Sportmonks.pull_match(match)
  
      if match.not_started?
        CheckMatchStartedWorker.perform_in(3.minutes, match_id)
      elsif match.in_progress? || match.finished?
        StartMatchWorker.perform_async(match_id)
      else
        SlackApp.delay.alert('Unknown Match Status', "match_id: #{match_id} sm_id: #{match.sm_id} pool_size: #{match.pool_size}")
      end
    end

  end

end