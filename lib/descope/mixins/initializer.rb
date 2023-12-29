# frozen_string_literal: true

require 'json'

module Descope
  module Mixins
    # Helper class for initializing the Descope API
    module Initializer
      attr_accessor :public_keys

      def initialize(config)
        options = Hash[config.map { |(k, v)| [k.to_sym, v] }]
        @base_uri = base_url(options)
        @headers = client_headers
        @project_id = options[:project_id] || ENV['DESCOPE_PROJECT_ID']
        @public_key = options[:public_key] || ENV['DESCOPE_PUBLIC_KEY']

        if @public_key.nil?
          @public_keys = {}
        else
          kid, pub_key, alg = validate_and_load_public_key(@public_key)
          @public_keys = { kid => [pub_key, alg] }
        end

        @skip_verify = options[:skip_verify]
        @secure = !@skip_verify
        @management_key = options[:management_key] || ENV['DESCOPE_MANAGEMENT_KEY']
        @timeout_seconds = options[:timeout_seconds] || Common::DEFAULT_TIMEOUT_SECONDS
        @jwt_validation_leeway = options[:jwt_validation_leeway]

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
        options[:descope_api_url] || ENV['DESCOPE_API_URL'] || Common::DEFAULT_BASE_URL
      end

      def authorization_header(pswd)
        return unless pswd

        bearer = "#{@project_id}:#{pswd}"
        add_headers('Authorization' => "Bearer #{bearer}")
      end

      def initialize_api(options)
        initialize_v1(options)
        if options.fetch(:management_key, nil)
          authorization_header(options[:management_key])
        else
          Rails.logger.debug 'no management key'
        end
      end

      def initialize_v1(_options)
        extend Descope::Api::V1
        extend Descope::Api::V1::Management
        extend Descope::Api::V1::Auth
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
      def validate_and_load_public_key(public_key)
        unless public_key.is_a?(String) || public_key.is_a?(Hash)
          raise AuthException.new(
            'Unable to load public key. Invalid public key error: (unknown type)',
            code: 500
          )
        end

        if public_key.is_a? String
          begin
            public_key = JSON.parse(public_key)
          rescue JSON::ParserError => e
            raise AuthException.new(
              "Unable to load public key. error: #{e.message}",
              code: 500
            )
          end
        end

        alg = public_key[Descope::Api::V1::Auth::ALGORITHM_KEY]
        if alg.nil?
          raise AuthException.new(
            'Unable to load public key. Missing property: alg',
            code: 500
          )
        end

        kid = public_key['kid']
        if kid.nil?
          raise AuthException.new(
            'Unable to load public key. Missing property: kid',
            code: 500
          )
        end

        begin
          # Load and validate public key
          [kid, JWT::JWK.new(public_key), alg]
        rescue JWT::JWKError => e
          raise AuthException.new(
            "Unable to load public key #{e.message}",
            code: 500
          )
        end
      end
    end
  end
end
