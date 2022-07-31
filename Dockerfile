# use ruby base image
FROM ruby:2.7.2

# set work
USER root
WORKDIR /code
VOLUME /code/shared

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
ENV SHARED_DIR="./shared"
RUN bash -c 'mkdir -p $SHARED_DIR/{pids,sockets,log,backups}' && \
    bash -c 'chmod 666 -R $SHARED_DIR' && \
    bash -c 'touch $SHARED_DIR/pids/unicorn.pid' && \
    bash -c 'touch $SHARED_DIR/log/cron.log'


# set-up unicorn_tess service
RUN bash -c 'cp ./docker/unicorn_tess /etc/init.d/unicorn_tess' && \
    bash -c 'chmod +x /etc/init.d/unicorn_tess' && \
    bash -c 'update-rc.d unicorn_tess defaults'

# define the entypoint
ENTRYPOINT ["docker/entrypoint.sh"]

# run rails server
EXPOSE 3000
CMD ["bundle","exec","rails","server","-b","0.0.0.0"]

# -- end of file #
