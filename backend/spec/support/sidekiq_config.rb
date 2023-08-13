require 'sidekiq/testing' 
Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.before(:each) { 
    allow(SlackApp).to receive(:delay).and_return(SlackApp)
    allow(Bitcoin).to receive(:delay).and_return(Bitcoin)
  }
end
