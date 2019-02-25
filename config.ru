RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)

if %w[production staging].include?(RACK_ENV)
  require 'raven'

  use Raven::Rack
end

require './app'
run App
