require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Betballist
  class Application < Rails::Application
    config.load_defaults 6.0
    config.generators.test_framework = nil
    config.active_record.belongs_to_required_by_default = false
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :put]
      end
    end
  end
end