FROM ruby:2.5.3-alpine3.9
ARG BUNDLE_INSTALL_CMD=bundle
ENV RACK_ENV=development
RUN echo ${BUNDLE_INSTALL_CMD}
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./
RUN apk --update --upgrade add build-base && \
  bundle check || ${BUNDLE_INSTALL_CMD} && \
  apk del build-base && \
  find / -type f -iname \*.apk-new -delete && \
  rm -rf /var/cache/apk/*

COPY . .
