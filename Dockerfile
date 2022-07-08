# use ruby base image
FROM ruby:2.7.2

# set work
USER root
WORKDIR /home/root/TeSS

# install dependencies
RUN apt-get update && \
    apt-get install libpq-dev libnode-dev nodejs imagemagick logrotate yarn cron mailutils -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# copy gemfile
COPY Gemfile Gemfile.lock ./

# install gems
RUN gem update --system && \
    gem install bundler && \
    bundle install

# copy code
COPY . .

# precompile assets
RUN bundle exec rake assets:precompile

# set-up shared directory and files
ENV SHARED_DIR = "./shared"
RUN bash -c 'mkdir -p $SHARED_DIR/{pids,sockets,log,backups}' && \
    bash -c 'touch $SHARED_DIR/pids/unicorn.pid' && \
    bash -c 'touch $SHARED_DIR/log/cron.log'

# set-up unicorn_tess service
RUN cp ./docker/unicorn_tess /etc/init.d/unicorn_tess && \
    chmod +x /etc/init.d/unicorn_tess && \
    update-rc.d unicorn_tess  defaults

# set-up
ENTRYPOINT ["docker/entrypoint.sh"]

# run unicorn service
#CMD service unicorn_tess start
CMD bundle exec unicorn -c ./config/unicorn.rb -E production -D

# run rails service
#EXPOSE 3000
#CMD bundle exec rails server -b 0.0.0.0

# -- end of file #
