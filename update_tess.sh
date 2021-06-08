#!/bin/bash

if [ "$#" -eq 0 ]; then
#    echo "Usage: update.sh <development | production>"
#    exit 0
    ENV="development"
else
    ENV=$1
fi

# stop services
sudo service nginx stop
sudo service unicorn_tess stop

# backup database
sudo sh ./scripts/pgsql_backup.sh postgres tess_$ENV ./shared/backups --exclude-schema=audit

# rebuild rails environment
#git pull origin master
bundle install --deployment
bundle exec rake db:migrate RAILS_ENV="$ENV"
bundle exec rake assets:clean RAILS_ENV="$ENV"
bundle exec rake assets:precompile RAILS_ENV="$ENV"
bundle exec rake sunspot:solr:reindex RAILS_ENV="$ENV"
# run tests
bundle exec rake db:migrate RAILS_ENV=test
bundle exec rake db:setup RAILS_ENV=test
bundle exec rake db:test:prepare
bundle exec rails test

# restart sidekiq
sudo touch tmp/restart.txt

pkill -f sidekiq
bundle exec sidekiq -d -e "$ENV" -L /tmp/sidekiq.log

# start services
sudo service unicorn_tess start
sudo service nginx start
#-- end of file --#
