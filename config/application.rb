# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module DanimeNicoTools
  class Application < Rails::Application
    config.load_defaults 5.1

    config.time_zone = 'Tokyo'

    config.i18n.default_locale = :ja

    config.generators.system_tests = nil

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.skip_routes = true
      g.template_engine :haml
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.eager_load_paths << Rails.root.join('lib')
  end
end
