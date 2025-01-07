# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
FROM ruby:3.3.0-alpine

ENV BUILD_PACKAGES="vim curl curl-dev ruby-dev build-base bash less" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev mysql-dev git" \
    RUBY_PACKAGES="ruby-json yaml" \
    LANG=ja_JP.UTF-8 \
    PATH=/root/.yarn/bin:$PATH \
    APP_ROOT=/usr/src/app

### set timezone ###########################

# RUN apk --update add tzdata \
#  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
#  && apk del tzdata \
#  && rm -rf /var/cache/apk/*

### install packages #######################
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
RUN apk update \
    && apk upgrade \
    && apk add --update $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES \
    && rm -rf /var/cache/apk/*
#    && rm -rf /var/cache/apk/* \
#    && /bin/bash \
#    && curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
#
#RUN source $NVM_DIR/nvm.sh \
#    && nvm install v18.4.0 \
#    && mkdir -p $APP_ROOT
RUN wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2 | tar -xj && \
    cd jemalloc-5.3.0 && \
    ./configure && \
    make && \
    make install
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

############################################
# Rails app lives here
WORKDIR /tmp

### install RubyGems #######################

COPY Gemfile Gemfile.lock ./

RUN bundle check || bundle install --jobs 5 --retry 5

# Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

WORKDIR $APP_ROOT
COPY . $APP_ROOT

EXPOSE 3000
