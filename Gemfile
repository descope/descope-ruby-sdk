source 'https://rubygems.org'
gemspec

group :development do
  gem 'terminal-notifier-guard', require: false unless ENV['CIRCLECI']
  gem 'coveralls', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'irb', require: false
end

group :test do
  gem 'webmock', require: false
  gem 'vcr', require: false
  gem 'simplecov-cobertura'
  gem 'timecop', require: false
  gem 'pp'
  gem 'rack-test', require: false
  gem 'dotenv', require: false
end
