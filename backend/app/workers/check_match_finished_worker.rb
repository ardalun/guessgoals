class CheckMatchFinishedWorker
  include Sidekiq::Worker

  # This is when the match should have been finished
  # Keep re-checking with a short wait until the match is actully finished

  def perform(match_id)
    return if !Rails.env.production?

    match = Match.find_by(id: match_id)
    is_in_started_state = (match.in_progress? || match.finished?) && match.pending_outcome?
    raise AppError::MatchMustBeInStartedState if !is_in_started_state

    Db.atomically do
      Sportmonks.pull_match(match) if !match.finished?
  
      if match.in_progress?
        CheckMatchFinishedWorker.perform_in(3.minutes, match_id)
      elsif match.finished?
        FinalizeMatchWorker.perform_async(match_id)
        Sportmonks.delay.pull_formations(match_id)
        Sportmonks.delay_for(1.hour).pull_highlights(match_id)
        PushMatchRecapToTelegramWorker.perform_at(1.hour.from_now, match_id)
      else
        SlackApp.delay.alert('Unknown Match Status', "match_id: #{match_id} sm_id: #{match.sm_id} pool_size: #{match.pool_size}")
      end
    end
  end

end