
module Descope
  module Mixins
    module Auth
      DEFAULT_TIMEOUT_SECONDS = 30

      def initialize(config)
        options = Hash[config.map { |k, v| [k.to_sym, v] }]
        @project_id = options[:project_id]
        @public_key = options[:public_key]
        @skip_verify = options[:skip_verify]
        @management_key = options[:management_key]
        @timeout_seconds = options[:timeout_seconds] || DEFAULT_TIMEOUT_SECONDS
        @jwt_validation_leeway = options[:jwt_validation_leeway]

        initialize_api(options)
      end

      def initialize_api(options)
        puts "initialize_api with #{options}"
      end
end