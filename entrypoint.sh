#!/bin/bash
#unset BUNDLE_PATH
#unset BUNDLE_BIN

set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

cd /app

bundle exec rake db:create RAILS_ENV=${RAILS_ENV}
bundle exec rake db:migrate RAILS_ENV=${RAILS_ENV}

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"