class StartMatchWorker
  include Sidekiq::Worker

  def perform(match_id)
    match = Match.find_by(id: match_id)
    match.start!
  end
end