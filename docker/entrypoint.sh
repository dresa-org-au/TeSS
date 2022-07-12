#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /code/tmp/pids/server.pid
rm -f /code/shared/pids/unicorn.pid

# initialise database
bundle exec rake db:setup

# add jobs to crontab
bundle exec whenever --update-crontab --set db_user="tess"

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

# --- end of file #