class ScheduleCheckMatchStartedWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    target_matches = Match
      .where(status: :not_started, check_started_scheduled: false)
      .where('starts_at < ?', 3.hours.from_now)
      .serialize(MatchSerializer)
    
    target_matches.each do |match_hash|
      CheckMatchStartedWorker.perform_at(match_hash[:starts_at], match_hash[:id])
    end
    
    target_match_ids = target_matches.pluck(:id)
    if target_match_ids.present?
      Match.where(id: target_matches.pluck(:id)).update_all(check_started_scheduled: true)
    end
  end
end