FROM ruby:2.5.1
# Setup the base OS
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends build-essential  \
    apt-transport-https curl ca-certificates gnupg2 apt-utils

# Install node from nodesource
# uncomment the next 2 lines for fix
 RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update -q \
# && apt-get install -qq -y nodejs \
 && apt-get install -y yarn

# Test
RUN yarn --version

ENV APP_HOME /app
ENV BUNDLER_VERSION 2.0.1
RUN gem install bundler -v "${BUNDLER_VERSION}" --force

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install --jobs 20 --retry 5

COPY package.json $APP_HOME/package.json
COPY yarn.lock $APP_HOME/yarn.lock
RUN yarn install

COPY . $APP_HOME

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG RAILS_ENV
ENV RAILS_ENV $RAILS_ENV
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

#ENV RAILS_ENV development
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["rails", "s", "puma", "-e", "${RAILS_ENV}", "-b", "0.0.0.0"]