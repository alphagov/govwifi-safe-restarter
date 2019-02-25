BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --jobs 20 --retry 5'

ifdef DEPLOYMENT
	BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --without test'
endif

DOCKER_COMPOSE = docker-compose -f docker-compose.yml
DOCKER_BUILD_CMD = docker-compose build $(BUNDLE_FLAGS)

ifndef JENKINS_URL
	DOCKER_COMPOSE += -f docker-compose.development.yml
endif

build: stop
	$(DOCKER_BUILD_CMD)

serve: build
	$(DOCKER_COMPOSE) up -d

lint: build
	$(DOCKER_COMPOSE) run --rm app bundle exec govuk-lint-ruby

test-rspec: serve
	$(DOCKER_COMPOSE) run --rm app rspec

test: test-rspec
	$(MAKE) stop

stop:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -f

.PHONY: build serve lint test test-rspec stop
