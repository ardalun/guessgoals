class DeclinePlayWorker
  include Sidekiq::Worker

  def perform(play_id)
    play = Play.find_by(id: play_id)
    play.decline!
  end
end