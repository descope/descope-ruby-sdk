# frozen_string_literal: true

require 'json'

module Descope
  module Mixins
    # Helper class for initializing the Descope API
    module Initializer
      attr_accessor :public_keys, :mlock

      def initialize(config)
        options = Hash[config.map { |(k, v)| [k.to_sym, v] }]
        @base_uri = base_url(options)
        @headers = client_headers
        @project_id = options[:project_id] || ENV['DESCOPE_PROJECT_ID'] || ''
        @headers['x-descope-project-id'] = @project_id
        @public_key = options[:public_key] || ENV['DESCOPE_PUBLIC_KEY']
        @mlock = Mutex.new
        log_level = options[:log_level] || ENV['DESCOPE_LOG_LEVEL'] || 'info'
        @logger ||= Descope::Mixins::Logging.logger_for(self.class.name, log_level, @project_id)

        @logger.debug("Initializing Descope API with project_id: #{@project_id} and base_uri: #{@base_uri}")

        if @public_key.nil?
          @public_keys = {}
        else
          kid, pub_key, alg = validate_and_load_public_key(@public_key)
          @public_keys = { kid => [pub_key, alg] }
        end

        @skip_verify = options[:skip_verify]
        @secure = !@skip_verify
        @management_key = options[:management_key] || ENV['DESCOPE_MANAGEMENT_KEY']
        @logger.debug("Management Key ID: #{@management_key}")
        @timeout_seconds = options[:timeout_seconds] || Common::DEFAULT_TIMEOUT_SECONDS
        @jwt_validation_leeway = options[:jwt_validation_leeway] || Common::DEFAULT_JWT_VALIDATION_LEEWAY

        if @project_id.to_s.empty?
          raise AuthException.new(
            'Unable to init Auth object because project_id cannot be empty. '\
                    'Set environment variable DESCOPE_PROJECT_ID or pass your Project ID to the init function.',
            code: 400
          )
        else
          initialize_api(options)
        end
      end

      def self.included(klass)
        klass.send :prepend, Initializer
      end

      def base_url(options)
        url = options[:descope_base_uri] || ENV['DESCOPE_BASE_URI'] || Common::DEFAULT_BASE_URL
        return url if url.start_with? 'http'

        raise AuthException.new('base url must start with http or https', code: 400)

      end

      def authorization_header(pswd = nil)
        pswd = @default_pswd if pswd.nil? || pswd.empty?
        bearer = "#{@project_id}:#{pswd}"
        add_headers('Authorization' => "Bearer #{bearer}")
      end

      def initialize_api(options)
        initialize_v1(options)
        @default_pswd = options.fetch(:management_key, ENV['DESCOPE_MANAGEMENT_KEY'])
        authorization_header
      end

      def initialize_v1(_options)
        extend Descope::Api::V1
        extend Descope::Api::V1::Management
        extend Descope::Api::V1::Auth
        extend Descope::Api::V1::Session
      end
    end
  end
end
