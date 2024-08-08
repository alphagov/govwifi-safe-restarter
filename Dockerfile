FROM ruby:3.2.2-alpine
ARG BUNDLE_INSTALL_CMD=bundle

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./
RUN apk --update --upgrade add build-base && \
  bundle check || ${BUNDLE_INSTALL_CMD} && \
  apk del build-base && \
  find / -type f -iname \*.apk-new -delete && \
  rm -rf /var/cache/apk/*

COPY . .
