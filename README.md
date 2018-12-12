TODO
  - Lock down Gem versions
  - Dependabot
  - Multi region eu-west-2
  - Disable this app so it doesn't restart again (check health checks first)
  - Linting
  - Sentry
  - This doesn't have to be a web app, delete the route
  - How does this deal with flapping instances?
  - Remove Sinatra, this isn't a web application
  - Use logger to print to STDOUT instead of puts

```ruby
bundle exec rake safe_restart[staging]
```
