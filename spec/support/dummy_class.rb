# frozen_string_literal: true

class DummyClass
  include Descope::Mixins::Logging
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
    @logger ||= Descope::Mixins::Logging.logger_for(self.class.name, 'info')
  end

  %i[get post post_file post_form put patch delete delete_with_body].each do |method|
    define_method(method) do |uri, body = {}, extra_headers = {}, pswd = nil|
      body = body.delete_if { |_, v| v.nil? }
      authorization_header(pswd) unless pswd.nil? || pswd.empty?
      {}
    end
  end

end
