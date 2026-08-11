# frozen_string_literal: true

class DummyClass
  include Descope::Mixins::Logging
  include Descope::Mixins::Headers
  include Descope::Mixins::Common
  include Descope::Mixins::Common::EndpointsV1
  include Descope::Mixins::Common::EndpointsV2
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
    @logger ||= Descope::Mixins::Logging.logger_for(self.class.name, ENV.fetch('DESCOPE_LOG_LEVEL', 'info'))
  end

  def add_headers(h = {})
    raise ArgumentError, 'Headers must be an object which responds to #to_hash' unless h.respond_to?(:to_hash)

    @headers ||= {}
    @headers.merge!(h.to_hash)
  end

  # Mirrors Descope::HttpClient#authorization_header. Specs that need to assert on the real bearer
  # should drive a Descope::Client instead - see spec/lib.descope/auth_management_key_spec.rb.
  def authorization_header(pswd = nil)
    bearer = [@project_id, pswd, @key].reject { |part| part.nil? || part.to_s.empty? }.join(':')
    { 'Authorization' => "Bearer #{bearer}" }
  end

  # The bare verbs stand in for authentication requests, the mgmt_ prefixed ones for management
  # requests, matching how Descope::Client routes them to its two HTTP clients.
  Descope::Mixins::HTTP::HTTP_METHODS.each do |method|
    [method, :"mgmt_#{method}"].each do |name|
      define_method(name) do |_uri, _body = {}, _extra_headers = {}, pswd = nil|
        add_headers(authorization_header(pswd)) unless pswd.nil? || pswd.empty?
        {}
      end
    end
  end
end
