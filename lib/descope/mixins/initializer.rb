module Descope
  module Mixins
    # Helper class for initializing the Descope API
    module Initializer

      def initialize(config)
        options = Hash[config.map { |(k, v)| [k.to_sym, v] }]
        @base_url = ENV['DESCOPE_API_URL'] || Common::DEFAULT_BASE_URL
        @headers = client_headers
        @project_id = options[:project_id] || ENV['DESCOPE_PROJECT_ID']
        @public_key = options[:public_key] || ENV['DESCOPE_PUBLIC_KEY']
        @skip_verify = options[:skip_verify]
        @secure = !@skip_verify
        @management_key = options[:management_key] || ENV['DESCOPE_MANAGEMENT_KEY']
        @timeout_seconds = options[:timeout_seconds] || Common::DEFAULT_TIMEOUT_SECONDS
        @jwt_validation_leeway = options[:jwt_validation_leeway]

        if @project_id.nil? || @project_id.empty?
          raise MissingProjectID.new(
            'Unable to init Auth object because project_id cannot be empty. Set environment variable DESCOPE_PROJECT_ID or pass your Project ID to the init function.',
            code: 400
          )
        else
          initialize_api(options)
        end
      end

      def authorization_header_bearer(pswd)
        bearer = @project_id

        return unless pswd

        bearer = "#{bearer}:#{pswd}"
        add_headers('Authorization' => "Bearer #{bearer}")
      end

      def initialize_api(options)
        if options.fetch(:management_key, nil)
          puts authorization_header_bearer(options[:management_key])
        else
          puts "no management key"
        end
      end
    end
  end
end
