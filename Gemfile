source "http://rubygems.org"
ruby File.read(".ruby-version").chomp

gem "activesupport", "~> 8.1.2.1"
gem "aws-sdk-ecs", "~> 1.245.0"
gem "aws-sdk-route53", "~> 1.70.0"
gem "multipart-post", "~> 2.2"
gem "rake", "~> 13.0.6"
gem "require_all", "~> 3.0"
gem "rexml", "~> 3.4"
gem "sentry-raven", "~> 3.1"

# required since ruby > 3.4
gem "base64"
gem "bigdecimal"
gem "ostruct"

group :test do
  gem "pry"
  gem "rspec"
  gem "rubocop-govuk"
end
