# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'dotenv', '~> 2.2', '>= 2.2.1'
gem 'em-websocket', '~> 0.5.1'
gem 'eventmachine', '~> 1.2', '>= 1.2.5'
gem 'faye-websocket'
gem 'redis'
gem 'thin', '~> 1.7', '>=   1.7.2'

gem 'activesupport', '~> 5.1', '>= 5.1.4'
gem 'bundler', '~> 1.16'
gem 'colored', '~> 1.2'
gem 'docker-api', '~> 1.34'
gem 'dogstatsd-ruby', '~> 3.1'
gem 'gssapi', '~> 1.2'
gem 'pry', '~> 0.11.3'
gem 'rake', '~> 12.3'
gem 'rspec', '~> 3.7'
gem 'rspec-benchmark', '~> 0.3.0'
gem 'rspec_junit_formatter', '~> 0.3.0'
gem 'rubocop', '~> 0.52.1'
gem 'ruby-prof', '~> 0.16.2'
gem 'statsd-ruby', '~> 1.4'
gem 'timecop', '~> 0.9.1'

ruby '2.5.0'
