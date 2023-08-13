class ApplicationMailer < ActionMailer::Base
  before_action do
    attachments.inline["logo-light-full.png"] = File.read("#{Rails.root}/app/assets/images/logo-light-full.png")
  end
end
