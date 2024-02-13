require 'rack/test'
require 'faker'
require 'json'
require 'concurrent'
require 'openssl'
require 'base64'
require 'descope'
require 'super_diff/rspec'
require 'factory_bot'

if RUBY_VERSION >= '2.7.2'
  # NOTE: https://bugs.ruby-lang.org/issues/17000
  Warning[:deprecated] = true
end

require 'simplecov'
require 'simplecov-html'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

if ENV['CI'] == 'true'
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

require 'webmock/rspec'
WebMock.allow_net_connect!

$LOAD_PATH.unshift File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Dir['./lib/*.rb'].each { |f| require f }
Dir['./lib/api/**/*.rb'].each { |f| require f }
Dir['./spec/support/**/*.rb'].each { |f| require f }
Dir['./spec/support/*.rb'].each { |f| require f }

include Descope::Api::V1::Management::Common
include Descope::Mixins::Common
include Descope::Mixins::Common::EndpointsV1
include Descope::Mixins::Common::EndpointsV2
include Descope::Api::V1::Auth

require 'rspec'
RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = 1000000
  end

  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end
end


def wait(time, increment = 5, elapsed_time = 0, &block)
  yield
rescue RSpec::Expectations::ExpectationNotMetError => e
  raise e if elapsed_time >= time
  sleep increment
  wait(time, increment, elapsed_time + increment, &block)
end

def entity_suffix
  'rubytest-210908'
end

puts "Entity suffix is #{entity_suffix}"
