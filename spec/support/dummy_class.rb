# frozen_string_literal: true

class DummyClass
  include Descope::Mixins::Headers
  include Descope::Mixins::Common
  include Descope::Mixins::Common::EndpointsV1
  include Descope::Api::V1::Management::Common
  include Descope::Api::V1::Auth

  attr_reader :base_uri, :headers

  def initialize
    @base_uri = 'test.descope.com'
    @headers = {
      'Content-Type' => 'application/json',
      'x-descope-sdk-name': 'ruby',
      'x-descope-sdk-ruby-version': RUBY_VERSION,
      'x-descope-sdk-version': Descope::SDK_VERSION
    }
    @project_id = 'P2abcde12345'
    @management_key = 'management_key'
  end

  %i[get post put patch delete delete_with_body].each do |method|
    define_method(method) do |uri, body = {}, extra_headers = {}|
      true
    end
  end
end
