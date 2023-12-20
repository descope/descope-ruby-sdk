require 'rack/test'
require 'faker'
require 'json'
require 'descope'
require 'super_diff/rspec'

require_relative '../lib/descope/api/v1/management/common'

if RUBY_VERSION >= '2.7.2'
  # NOTE: https://bugs.ruby-lang.org/issues/17000
  Warning[:deprecated] = true
end

require 'simplecov'
SimpleCov.start

if ENV['CI'] == 'true'
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

require 'dotenv'
Dotenv.load

require 'webmock/rspec'
WebMock.allow_net_connect!

require 'vcr'
VCR.configure do |config|
  # Uncomment the line below to record new VCR cassettes.
  # When this is commented out, VCR will reject all outbound HTTP calls.
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.configure_rspec_metadata!
  config.hook_into :webmock
  config.filter_sensitive_data('MANAGEMENT_KEY') { ENV['MANAGEMENT_KEY'] }


  ENV['PROJECT_ID'] = 'dummyProjectId'
  ENV['MANAGEMENT_KEY'] = 'dummyManagementKey'
end

$LOAD_PATH.unshift File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Dir['./lib/*.rb'].each { |f| require f }
Dir['./lib/api/**/*.rb'].each { |f| require f }
Dir['./spec/support/**/*.rb'].each { |f| require f }
Dir['./spec/support/*.rb'].each { |f| require f }

require 'rspec'
RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = 1000000
  end
end

include Descope::Api::V1::Management::Common

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
