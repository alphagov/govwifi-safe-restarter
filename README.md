# GovWifi Safe Restarter

This application is responsible for restarting the frontend RADIUS servers in a safe way.

## Table of Contents

* [Overview](#overview)
  * [Dependencies](#dependencies)
* [Developing](#developing)
  * [Deploying changes](#deploying-changes)
* [Running the application](#running-the-application)
* [Debugging](#debugging)
* [TODO](#todo)
* [Licence](#licence)

## Overview

This application is run as a background job (daily) and does a rolling restart of the frontend cluster.
These servers are restarted so they can pull in new configurations, certificates and do security updates.

It nominates a random canary (1 of the 6 frontend servers) and restarts the ECS task running on it.
It then monitors the canary to ensure it is healthy and serving traffic before moving onto the rest.

It runs on both regions, eu-west-1 and eu-west-2.

If the canary doesn't come backup, it terminates.
We will then be notified about the canary via the failing Route53 health check.

### Dependencies

* AWS SDK -ECS
* AWS SDK -ROUTE53

## Developing

The Makefile contains commonly used commands for working with this app:

* `make lint` runs the Ruby linter.
* `make test` runs all the automated tests.
* `make serve` starts the application on localhost.

### Deploying changes

Merging to `master` will automatically deploy this API to staging.
To deploy to production, choose _Deploy to production_ in the jenkins pipeline when prompted.

## Running the application

```ruby
bundle exec rake safe_restart[staging]
```

## Debugging

Results of the daily restart are printed to a CloudWatch log group called `[env]-safe-restart-docker-log-group`

## TODO
  - Lock down Gem versions
  - Dependabot
  - Sentry
  - Run Rake as a standalone task (no Sinatra required)
  - Use the `sensible logging` gem

## Licence

This codebase is released under [the MIT License][mit].

[mit]: LICENCE
