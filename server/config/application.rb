require_relative 'boot'

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'

Bundler.require(*Rails.groups)

module ThreeBigThings
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true

    config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', 'three_big_things_development_secret_key_base_placeholder')
  end
end
