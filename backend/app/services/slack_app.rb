class SlackApp
  
  PAYMENTS_WEBHOOK_URL = {
    'production'  => "https://hooks.slack.com/services/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",
    'development' => "https://hooks.slack.com/services/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" 
  }

  APP_ALERTS_WEBHOOK_URL = {
    'production'  => "https://hooks.slack.com/services/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",
    'development' => "https://hooks.slack.com/services/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"
  }

  def self.get_tx_link(txid)
    if Rails.env.development?
      return "https://live.blockcypher.com/btc-testnet/tx/#{txid}"
    else
      return "https://live.blockcypher.com/btc/tx/#{txid}"
    end
  end

  def self.alert(title, msg, color='warning') # colors: good, warning, danger
    return if self.connection_blocked?
    notifier = Slack::Notifier.new(APP_ALERTS_WEBHOOK_URL[Rails.env])
    notifier.post(
      attachments: [
        {
          title: title,
          text: msg,
          color: color
        }
      ]
    )
  end

  def self.notify_sending_bitcoin(amount, address_code, txid, performed_at)
    return if self.connection_blocked?
    notifier = Slack::Notifier.new(PAYMENTS_WEBHOOK_URL[Rails.env])
    notifier.post(
      attachments: [
        {
          title: "Send: #{amount}",
          title_link: self.get_tx_link(txid),
          text: "*Address:* #{address_code}\n*txid:* #{txid}",
          footer: performed_at,
          color: '#f64747'
        }
      ]
    )
  end

  def self.notify_receiving_bitcoin_on_app_address(amount, address_code, txid, performed_at)
    return if self.connection_blocked?
    notifier = Slack::Notifier.new(PAYMENTS_WEBHOOK_URL[Rails.env])
    notifier.post(
      attachments: [
        {
          title: "App Receive: #{amount}",
          title_link: self.get_tx_link(txid),
          text: "*Address:* #{address_code}\n*txid:* #{txid}",
          footer: performed_at,
          color: '#03A678'
        }
      ]
    )
  end

  def self.notify_receiving_bitcoin_on_nonapp_address(amount, address_code, txid, performed_at)
    return if self.connection_blocked?
    notifier = Slack::Notifier.new(PAYMENTS_WEBHOOK_URL[Rails.env])
    notifier.post(
      attachments: [
        {
          title: "Nonapp Receive: #{amount}",
          title_link: self.get_tx_link(txid),
          text: "*Address:* #{address_code}\n*txid:* #{txid}",
          footer: performed_at,
          color: '#03A678'
        }
      ]
    )
  end

  def self.notify_receiving_transaction_confirmation(txid, performed_at, confirmations)
    return if self.connection_blocked?
    notifier = Slack::Notifier.new(PAYMENTS_WEBHOOK_URL[Rails.env])
    notifier.post(
      attachments: [
        {
          title: "Confirmation: #{confirmations}",
          title_link: self.get_tx_link(txid),
          text: "*txid:* #{txid}",
          footer: performed_at,
          color: '#03A678'
        }
      ]
    )
  end

  def self.connection_blocked?
    return Rails.env.test?
  end
end