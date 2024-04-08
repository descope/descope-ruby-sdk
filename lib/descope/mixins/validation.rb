# frozen_string_literal: true

module Descope
  module Mixins
    # Module to provide validation for specific data structures.
    module Validation
      def validate_tenants(key_tenants)
        raise ArgumentError, 'key_tenants should be an Array of hashes' unless key_tenants.is_a? Array

        key_tenants.each do |tenant|
          unless tenant.is_a? Hash
            raise ArgumentError,
                  'Each tenant should be a Hash of tenant_id and optional role_names array'
          end

          tenant_symbolized = tenant.transform_keys(&:to_sym)

          raise ArgumentError, "Missing tenant_id key in tenant: #{tenant}" unless tenant_symbolized.key?(:tenant_id)
        end
      end

      def validate_login_id(login_id)
        raise AuthException, 'login_id cannot be empty' unless login_id.is_a?(String) && !login_id.empty?
      end

      def validate_user_id(user_id)
        raise Descope::ArgumentException, 'Missing user id' if user_id.nil? || user_id.to_s.empty?
      end

      def validate_password(password)
        raise AuthException, 'password cannot be empty' unless password.is_a?(String) && !password.empty?
      end

      def validate_email(email)
        raise AuthException.new('email cannot be empty', code: 400) unless email.is_a?(String) && !email.empty?
      end

      def validate_token_not_empty(token)
        raise AuthException.new('Token cannot be empty', code: 400) unless token.is_a?(String) && !token.empty?
      end

      def validate_refresh_token_not_nil(refresh_token)
        return unless refresh_token.nil? || refresh_token.empty?

        raise AuthException.new('Refresh token is required to refresh a session', code: 400)
      end

      def validate_phone(method, phone)
        phone_number_is_invalid = !phone.match?(PHONE_REGEX)

        raise AuthException.new('Phone number cannot be empty', code: 400) unless phone.is_a?(String) && !phone.empty?
        raise AuthException.new('Invalid pattern for phone number', code: 400) if phone_number_is_invalid

        valid_methods = DeliveryMethod.constants.map { |constant| DeliveryMethod.const_get(constant) }

        # rubocop:disable Style/LineLength
        unless valid_methods.include?(method)
          valid_methods_names = valid_methods.map { |m| "DeliveryMethod::#{DeliveryMethod.constants[valid_methods.index(m)]}" }.join(', ')
          raise AuthException.new("Delivery method should be one of the following: #{valid_methods_names}", code: 400)
        end

      end

      def verify_provider(oauth_provider)
        return false if oauth_provider.to_s.empty? || oauth_provider.nil?

        true
      end

      def validate_tenant(tenant)
        raise AuthException.new('Tenant cannot be empty', code: 400) unless tenant.is_a?(String) && !tenant.empty?
      end

      def validate_redirect_url(return_url)
        return if return_url.is_a?(String) && !return_url.empty?

        raise AuthException.new('Return_url cannot be empty', code: 400)
      end

      def validate_code(code)
        raise AuthException.new('Code cannot be empty', code: 400) unless code.is_a?(String) && !code.empty?
      end

      def validate_scim_group_id(group_id)
        return if group_id.is_a?(String) && !group_id.empty?

        raise AuthException.new('SCIM Group ID cannot be empty', code: 400)

      end
    end
  end
end
