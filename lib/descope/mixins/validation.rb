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
        raise AuthException.new('Phone number cannot be empty', code: 400) unless phone.is_a?(String) && !phone.empty?
        raise AuthException.new('Invalid phone number', code: 400) unless phone.match?(PHONE_REGEX)
        raise AuthException.new('Invalid delivery method', code: 400) unless [
          DeliveryMethod::WHATSAPP, DeliveryMethod::SMS
        ].include?(method)
      end

      def verify_provider(oauth_provider)
        return false if oauth_provider.to_s.empty? || oauth_provider.nil?

        true
      end
    end
  end
end
