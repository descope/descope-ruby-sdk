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
  gem 'simplecov-cobertura'
  gem 'timecop', require: false
  gem 'rack-test', require: false
  gem 'dotenv', require: false
  gem 'super_diff', require: false
  gem 'factory_bot', require: 'false'
  gem 'mailmock', git: 'git@github.com:descope/mailmock.git', glob: 'sdk/ruby/*.gemspec'
  gem 'selenium-webdriver', require: false
  gem 'rotp', require: false
end
