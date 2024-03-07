require 'rack/test'
require 'faker'
require 'json'
require 'concurrent'
require 'openssl'
require 'base64'
require 'descope'
require 'super_diff/rspec'
require 'factory_bot'
require 'simplecov'
require 'simplecov-html'
require 'rspec'

$LOAD_PATH.unshift File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

include Descope::Api::V1::Management::Common
include Descope::Mixins::Common
include Descope::Mixins::Common::EndpointsV1
include Descope::Mixins::Common::EndpointsV2
include Descope::Api::V1::Auth

Dir['./lib/*.rb'].each { |f| require f }
Dir['./lib/api/**/*.rb'].each { |f| require f }
Dir['./spec/support/**/*.rb'].each { |f| require f }
Dir['./spec/support/*.rb'].each { |f| require f }

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

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
