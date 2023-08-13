class PushMatchRecapToTelegramWorker
  include Sidekiq::Worker

  def perform(match_id)
    match = Match.find_by(id: match_id)
    highlight_file_id = self.find_highlight_in_skysport_channel(match)
    if highlight_file_id.nil?
      highlight_file_id = self.find_on_dazn_youtube(match)
    end

    if match.starts_at > 465.minutes.ago && highlight_file_id.blank?
      PushMatchRecapToTelegramWorker.perform_at(1.hour.from_now, match_id)
      return
    end

    if highlight_file_id.present?
      summary_md = "*#{match._home_team['name']} #{match.home_score} - #{match.away_score} #{match._away_team['name']}*\n#{match._league['name']}\n#{match.starts_at.utc.strftime('%b %e - %l:%M %p GMT')}\n#{match.stadium}\n\n*Goals*\n" + match.goals.map { |goal| "#{goal['minute']}\' - #{goal['team'] == 'home' ? match._home_team['name'] : match._away_team['name']} - #{goal['player_name']}" }.join("\n")
      push_request_body = {
        chat_id: '@guessgoals',
        video: highlight_file_id,
        caption: summary_md,
        parse_mode: 'Markdown',
        disable_notification: true
      }

      push_url = "https://api.telegram.org/bot#{ENV['GUESSGOALSBOT_API_TOKEN']}/sendVideo"
      HTTParty.post(push_url, body: push_request_body.to_json, headers: {'Content-Type' => 'application/json'})
      match.update!(pushed_to_social_media: true)
    end
  end

  def find_highlight_in_skysport_channel(match)
    result = "#{match.home_score}-#{match.away_score}"
    searches = match._home_team['name'].split(" ") + match._away_team['name'].split(" ")
    highlight_file_id = nil
    searches.each do |search|
      query = "#{search} #{result} highlights"
      forward_message_id = system `python3 #{Rails.root}/app/lib/find_and_forward_highlight.py #{ENV['TELEGRAM_APP_ID']} #{ENV['TELEGRAM_APP_HASH']} \'#{query}\' #{(match.starts_at + 105.minutes).to_i} #{DateTime.now.to_i}`
      if forward_message_id.present?
        guessgoalbot_get_update_url = "https://api.telegram.org/bot#{ENV['GUESSGOALSBOT_API_TOKEN']}/getUpdates?offset=-100&limit=100"
        updates = JSON.try(:parse, (HTTParty.get(guessgoalbot_get_update_url).response.body)).fetch('result', [])
        target_update = updates.find { |update| update.fetch('message', {}).fetch('forward_from_message_id', nil).to_i == forward_message_id.to_i }
        highlight_file_id = target_update.fetch('message', {}).fetch('video', {}).fetch('file_id', nil)
        break
      end
    end
    return highlight_file_id
  end

  def find_on_dazn_youtube(match)
    youtube_api_token = 'AIzaSyAr_mh5sgKoVl0wRGkFS51OQUFH5TEFz0Y'
    dazn_channel_id = 'UCaNeFN9L6CHcfn_FA7I_Wng'
    match_finish_time = match.starts_at + 105.minute
    query = "#{match._home_team['name']} vs #{match._away_team['name']} highlights"
    url = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{query}&channelId=#{dazn_channel_id}&publishedAfter=#{match_finish_time.rfc3339()}&publishedBefore=#{DateTime.now.rfc3339()}&key=#{youtube_api_token}"
    search_result = JSON.try(:parse, (HTTParty.get(url).response.body))
    found_video_id = search_result.fetch('items', []).fetch(0, {}).fetch('id', {}).fetch('videoId', nil)
    
    return nil if found_video_id.nil?

    # Download it 
    uuid = SecureRandom.uuid
    temp_file = "tmp/highligh_#{match.id}.mp4"
    puts "Downloading: https://www.youtube.com/watch?v=#{found_video_id}"
    download_result = system "youtube-dl https://www.youtube.com/watch?v=#{found_video_id} -o #{temp_file}"
    return nil if !download_result

    # Upload it
    id_in_caption = "match_#{match.id}"
    upload_result = system "python3 #{Rails.root}/app/lib/send_file_to_guessgoalsbot.py #{ENV['TELEGRAM_APP_ID']} #{ENV['TELEGRAM_APP_HASH']} #{temp_file} #{id_in_caption}"
    return nil if !upload_result
    system "rm -rf #{temp_file}"
    
    # Find file_id
    guessgoalbot_get_update_url = "https://api.telegram.org/bot#{ENV['GUESSGOALSBOT_API_TOKEN']}/getUpdates?offset=-100&limit=100"
    updates = JSON.try(:parse, (HTTParty.get(guessgoalbot_get_update_url).response.body)).fetch('result', [])
    target_update = updates.find { |update| update.fetch('message', {}).fetch('caption', nil) == id_in_caption }
    return target_update.fetch('message', {}).fetch('video', {}).fetch('file_id', nil)
  end
end