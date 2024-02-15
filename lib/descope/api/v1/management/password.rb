# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module Password
          include Descope::Api::V1::Management::Common

          def get_password_settings(tenant_id)
            # Get password settings for the provided tenant id.
            get(PASSWORD_SETTINGS_PATH, { tenantId: tenant_id })
          end

          def update_password_settings(settings)
            unless settings.is_a?(Hash)
              raise Descope::ArgumentException.new('Password settings must be a Hash', code: 400)
            end

            # Update password settings for the provided tenant id.
            body = compose_settings_body(settings)
            post(PASSWORD_SETTINGS_PATH, body)
          end

          private

          # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def compose_settings_body(settings)
            body = {}
            body['minLength'] = settings[:min_length] if settings.key?(:min_length)
            body['lowercase'] = settings[:lowercase] if settings.key?(:lowercase)
            body['uppercase'] = settings[:uppercase] if settings.key?(:uppercase)
            body['number'] = settings[:number] if settings.key?(:number)
            body['nonAlphanumeric'] = settings[:non_alphanumeric] if settings.key?(:non_alphanumeric)
            body['expiration'] = settings[:expiration] if settings.key?(:expiration)
            body['expirationWeeks'] = settings[:expiration_weeks] if settings.key?(:expiration_weeks)
            body['reuse'] = settings[:reuse] if settings.key?(:reuse)
            body['reuseAmount'] = settings[:reuse_amount] if settings.key?(:reuse_amount)
            body['lock'] = settings[:lock] if settings.key?(:lock)
            body['lockAttempts'] = settings[:lock_attempts] if settings.key?(:lock_attempts)
            body['emailServiceProvider'] = settings[:email_service_provider] if settings.key?(:email_service_provider)
            body['emailSubject'] = settings[:email_subject] if settings.key?(:email_subject)
            body['emailBody'] = settings[:email_body] if settings.key?(:email_body)
            body['resetAuthMethod'] = settings[:reset_auth_method] if settings.key?(:reset_auth_method)
            body['emailBodyPlainText'] = settings[:email_body_plain_text] if settings.key?(:email_body_plain_text)
            if settings.key?(:use_email_body_plain_text)
              body['useEmailBodyPlainText'] = settings[:use_email_body_plain_text]
            end
            body['tenantId'] = settings[:tenant_id] if settings.key?(:tenant_id)
            body['enabled'] = settings[:enabled] if settings.key?(:enabled)
            body
          end
        end
      end
    end
  end
end
