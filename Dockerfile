FROM ruby:2.4.1
WORKDIR /app
COPY Gemfile* /app/
RUN gem install bundler --no-ri --no-rdoc && \
    bundle install --jobs $(nproc) --retry 5
COPY . .
CMD thin start -R config.ru -t 1000 -p 3000
