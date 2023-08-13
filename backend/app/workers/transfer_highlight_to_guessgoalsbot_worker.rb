class TransferHighlightToGuessgoalsbotWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'telegram_transfers'

  def perform(highlight_id)
    highlight = Highlight.find_by(id: highlight_id)
    temp_file = "tmp/uuid_#{highlight.uuid}.mp4"
    download_result = system "youtube-dl #{highlight.original_link} -o #{temp_file}"
    if !download_result
      highlight.set_transfer_failed!
      return
    end
    uuid_in_caption = "uuid_#{highlight.uuid}"
    upload_result = system "python3 #{Rails.root}/app/lib/send_file_to_guessgoalsbot.py #{ENV['TELEGRAM_APP_ID']} #{ENV['TELEGRAM_APP_HASH']} #{temp_file} #{uuid_in_caption}"
    if !upload_result
      highlight.set_transfer_failed!
      return
    end
    system "rm -rf #{temp_file}"
    begin
      guessgoalbot_get_update_url = "https://api.telegram.org/bot#{ENV['GUESSGOALSBOT_API_TOKEN']}/getUpdates?offset=-100&limit=100"
      updates = JSON.try(:parse, (HTTParty.get(guessgoalbot_get_update_url).response.body)).fetch('result', [])
      target_update = updates.find { |update| update.fetch('message', {}).fetch('caption', nil) == uuid_in_caption }
      file_id = target_update.fetch('message', {}).fetch('video', {}).fetch('file_id', nil)
      highlight.set_transfer_done!(file_id)
    rescue
      highlight.set_transfer_failed!
    end
  end
end