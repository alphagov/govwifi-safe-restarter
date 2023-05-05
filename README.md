# GovWifi Safe Restarter

This application is responsible for restarting the frontend RADIUS servers in a safe way.

## Table of Contents

* [Overview](#overview)
  * [Dependencies](#dependencies)
* [Developing](#developing)
  * [Deploying changes](#deploying-changes)
* [Running the application](#running-the-application)
* [Debugging](#debugging)
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

You can find in depth instructions on using our deploy process [here](https://docs.google.com/document/d/1ORrF2HwrqUu3tPswSlB0Duvbi3YHzvESwOqEY9-w6IQ/) (you must be member of the GovWifi Team to access this document).

## Running the application

```ruby
bundle exec rake safe_restart[staging]
```

## Debugging

Results of the daily restart are printed to a CloudWatch log group called `[env]-safe-restart-docker-log-group`

## Licence

This codebase is released under [the MIT License][mit].

[mit]: LICENCE
