# frozen_string_literal: true

require_relative '../exception'

module Descope
  module Mixins
    # Common values and methods
    module Common
      DEFAULT_BASE_URL = 'https://api.descope.com' # pragma: no cover
      DEFAULT_TIMEOUT_SECONDS = 60
      DEFAULT_JWT_VALIDATION_LEEWAY = 5
      # Using E164 format,\A and \z are start and end of string respectively, to prevent multiline matching
      PHONE_REGEX = /\A\+[1-9]\d{1,14}\z/

      SESSION_COOKIE_NAME = 'DS'
      REFRESH_SESSION_COOKIE_NAME = 'DSR'

      SESSION_TOKEN_NAME = 'sessionToken'
      REFRESH_SESSION_TOKEN_NAME = 'refreshSessionToken'
      COOKIE_DATA_NAME = 'cookieData'

      REDIRECT_LOCATION_COOKIE_NAME = 'Location'

      module DeliveryMethod
        WHATSAPP = 1
        SMS = 2
        EMAIL = 3
        VOICE = 4
      end

      def get_method_string(method)
        name = {
          DeliveryMethod::WHATSAPP => 'whatsapp',
          DeliveryMethod::SMS => 'sms',
          DeliveryMethod::EMAIL => 'email',
          DeliveryMethod::VOICE => 'voice'
        }[method]

        raise ArgumentException, "Unknown delivery method: #{method}" if name.nil?

        name
      end

      def deep_copy(obj)
        Marshal.load(Marshal.dump(obj))
      end

      module EndpointsV1
        REFRESH_TOKEN_PATH = '/v1/auth/refresh'
        SELECT_TENANT_PATH = '/v1/auth/tenant/select'
        LOGOUT_PATH = '/v1/auth/logout'
        LOGOUT_ALL_PATH = '/v1/auth/logoutall'
        VALIDATE_SESSION_PATH = '/v1/auth/validate'
        ME_PATH = '/v1/auth/me'

        # access key
        EXCHANGE_AUTH_ACCESS_KEY_PATH = '/v1/auth/accesskey/exchange'

        # otp
        SIGN_UP_AUTH_OTP_PATH = '/v1/auth/otp/signup'
        SIGN_IN_AUTH_OTP_PATH = '/v1/auth/otp/signin'
        SIGN_UP_OR_IN_AUTH_OTP_PATH = '/v1/auth/otp/signup-in'
        VERIFY_CODE_AUTH_PATH = '/v1/auth/otp/verify'
        UPDATE_USER_EMAIL_OTP_PATH = '/v1/auth/otp/update/email'
        UPDATE_USER_PHONE_OTP_PATH = '/v1/auth/otp/update/phone'

        # nOTP
        SIGN_UP_AUTH_NOTP_PATH = '/v1/auth/notp/signup'
        SIGN_IN_AUTH_NOTP_PATH = '/v1/auth/notp/signin'
        SIGN_UP_OR_IN_AUTH_NOTP_PATH = '/v1/auth/notp/signup-in'
        GET_NOTP_SESSION_PATH = '/v1/auth/notp/pending-session'

        # magiclink
        SIGN_UP_AUTH_MAGICLINK_PATH = '/v1/auth/magiclink/signup'
        SIGN_IN_AUTH_MAGICLINK_PATH = '/v1/auth/magiclink/signin'
        SIGN_UP_OR_IN_AUTH_MAGICLINK_PATH = '/v1/auth/magiclink/signup-in'
        VERIFY_MAGICLINK_AUTH_PATH = '/v1/auth/magiclink/verify'
        GET_SESSION_MAGICLINK_AUTH_PATH = '/v1/auth/magiclink/pending-session'
        UPDATE_USER_EMAIL_MAGICLINK_PATH = '/v1/auth/magiclink/update/email'
        UPDATE_USER_PHONE_MAGICLINK_PATH = '/v1/auth/magiclink/update/phone'

        # enchantedlink
        SIGN_UP_AUTH_ENCHANTEDLINK_PATH = '/v1/auth/enchantedlink/signup'
        SIGN_IN_AUTH_ENCHANTEDLINK_PATH = '/v1/auth/enchantedlink/signin'
        SIGN_UP_OR_IN_AUTH_ENCHANTEDLINK_PATH = '/v1/auth/enchantedlink/signup-in'
        VERIFY_ENCHANTEDLINK_AUTH_PATH = '/v1/auth/enchantedlink/verify'
        GET_SESSION_ENCHANTEDLINK_AUTH_PATH = '/v1/auth/enchantedlink/pending-session'
        UPDATE_USER_EMAIL_ENCHANTEDLINK_PATH = '/v1/auth/enchantedlink/update/email'

        # oauth
        OAUTH_START_PATH = '/v1/auth/oauth/authorize'
        OAUTH_EXCHANGE_TOKEN_PATH = '/v1/auth/oauth/exchange'
        OAUTH_CREATE_REDIRECT_URL_FOR_SIGN_IN_REQUEST_PATH = 'v1/auth/oauth/authorize/signin'
        OAUTH_CREATE_REDIRECT_URL_FOR_SIGN_UP_REQUEST_PATH = 'v1/auth/oauth/authorize/signup'

        # saml
        AUTH_SAML_START_PATH = '/v1/auth/saml/authorize'
        SAML_EXCHANGE_TOKEN_PATH = '/v1/auth/saml/exchange'

        # totp
        SIGN_UP_AUTH_TOTP_PATH = '/v1/auth/totp/signup'
        VERIFY_TOTP_PATH = '/v1/auth/totp/verify'
        UPDATE_TOTP_PATH = '/v1/auth/totp/update'

        # webauthn
        SIGN_UP_AUTH_WEBAUTHN_START_PATH = '/v1/auth/webauthn/signup/start'
        SIGN_UP_AUTH_WEBAUTHN_FINISH_PATH = '/v1/auth/webauthn/signup/finish'
        SIGN_IN_AUTH_WEBAUTHN_START_PATH = '/v1/auth/webauthn/signin/start'
        SIGN_IN_AUTH_WEBAUTHN_FINISH_PATH = '/v1/auth/webauthn/signin/finish'
        SIGN_UP_OR_IN_AUTH_WEBAUTHN_START_PATH = '/v1/auth/webauthn/signup-in/start'
        UPDATE_AUTH_WEBAUTHN_START_PATH = '/v1/auth/webauthn/update/start'
        UPDATE_AUTH_WEBAUTHN_FINISH_PATH = '/v1/auth/webauthn/update/finish'

        # password
        SIGN_UP_PASSWORD_PATH = '/v1/auth/password/signup'
        SIGN_IN_PASSWORD_PATH = '/v1/auth/password/signin'
        SEND_RESET_PASSWORD_PATH = '/v1/auth/password/reset'
        UPDATE_PASSWORD_PATH = '/v1/auth/password/update'
        REPLACE_PASSWORD_PATH = '/v1/auth/password/replace'
        PASSWORD_POLICY_PATH = '/v1/auth/password/policy'
      end

      module EndpointsV2
        PUBLIC_KEY_PATH = '/v2/keys'
      end
    end
  end
end
