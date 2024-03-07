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

  def authorization_header(pswd = nil)
    pswd = @default_pswd if pswd.nil? || pswd.empty?
    bearer = "#{@project_id}:#{pswd}"
    add_headers('Authorization' => "Bearer #{bearer}")
  end

  %i[get post post_file post_form put patch delete delete_with_body].each do |method|
    define_method(method) do |uri, body = {}, extra_headers = {}, pswd = nil|
      body = body.delete_if { |_, v| v.nil? }
      authorization_header(pswd) unless pswd.nil? || pswd.empty?
      {}
    end
  end

end
