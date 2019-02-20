RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)

if %w[production staging].include?(RACK_ENV)
  require 'raven'

  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.environments = ['staging', 'production']
  end

  use Raven::Rack
end

require './app'
run App
