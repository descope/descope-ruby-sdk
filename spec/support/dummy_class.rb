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
    @public_keys = {}
    @mlock = Mutex.new
  end

  %i[get post put patch delete delete_with_body].each do |method|
    define_method(method) do |uri, token, body = {}, extra_headers = {}|
      body = body.delete_if { |_, v| v.nil? }
      authorization_header(token) unless token.nil?
      true
    end
  end
end
