# Base Ruby layer
FROM ruby:2.3.4

# Add system libraries layer
RUN apt-get update -qq && apt-get install -y cron vim postgresql postgresql-contrib libpq-dev

# Allow crontab to be executed
RUN chmod 600 /etc/crontab

# Set the working directory to /app
RUN mkdir /app
WORKDIR /app

# Install all needed gems
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN gem install bundler
RUN bundle install

# Copy the current directory contents into the container at /app
ADD . /app

# Turn on cache in dev environment
RUN rails dev:cache

# Start server
CMD ["rails","server","-b", "0.0.0.0"]
