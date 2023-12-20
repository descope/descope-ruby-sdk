# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module User
          def load_user(login_id: nil)
            # Retrieve user information based on the provided Login ID
            if login_id.nil? || login_id.empty?
              raise Descope::ArgumentException, "Failed loading user by login_id #{login_id}"
            end

            path = Common::USER_LOAD_PATH
            request_params = {}
            request_params[:loginId] = login_id unless login_id.nil?
            get(path, request_params)
          end

          def load_by_user_id(user_id: nil)
            # Retrieve user information based on the provided user ID
            # The user ID can be found on the user's JWT.
            raise Descope::ArgumentException, "Missing user id" if user_id.nil? || user_id.empty?

            path = Common::USER_LOAD_PATH
            request_params = {}
            request_params[:userId] = user_id
            get(path, request_params)
          end

          # Create a new test user.
          # The login_id is required and will determine what the user will use to sign in.
          # Make sure the login id is unique for test. All other fields are optional.
          def create_user(
            login_id: nil,
            email: nil,
            phone: nil,
            display_name: nil,
            given_name: nil,
            middle_name: nil,
            family_name: nil,
            role_names: [],
            user_tenants: [],
            picture: nil,
            custom_attributes: nil,
            verified_email: nil,
            verified_phone: nil,
            invite_url: nil,
            additional_login_ids: nil
          )
            if login_id.nil? || login_id.empty?
              raise Descope::ArgumentException, 'login_id is required to create a user'
            end

            # if email.nil? || phone.nil?
            #   raise Descope::ArgumentException, 'email or phone is required to create a user'
            # end

            role_names ||= []
            user_tenants ||= []
            path = Common::USER_CREATE_PATH
            request_params = _compose_create_body(
              login_id: login_id,
              email: email,
              phone: phone,
              display_name: display_name,
              given_name: given_name,
              middle_name: middle_name,
              family_name: family_name,
              role_names: role_names,
              user_tenants: user_tenants,
              invite: false,
              test: false,
              picture: picture,
              custom_attributes: custom_attributes,
              verified_email: verified_email,
              verified_phone: verified_phone,
              invite_url: invite_url,
              send_mail: nil,
              send_sms: nil,
              additional_login_ids: additional_login_ids,
            )
            post(path, request_params)
          end


          private
          def _compose_create_body(
            login_id: nil,
            email: nil,
            phone: nil,
            display_name: nil,
            given_name: nil,
            middle_name: nil,
            family_name: nil,
            role_names: nil,
            user_tenants: nil,
            invite: false,
            test: false,
            picture: nil,
            custom_attributes: nil,
            verified_email: nil,
            verified_phone: nil,
            invite_url: nil,
            send_mail: nil,
            send_sms: nil,
            additional_login_ids: nil
          )
            body = _compose_update_body(
              login_id: login_id,
              email: email,
              phone: phone,
              display_name: display_name,
              given_name: given_name,
              middle_name: middle_name,
              family_name: family_name,
              role_names: role_names,
              user_tenants: user_tenants,
              test: test,
              picture: picture,
              custom_attributes: custom_attributes,
              additional_login_ids: additional_login_ids
            )
            body[:invite] = invite
            body[:verifiedEmail] = verified_email unless verified_email.nil? || !verified_email.empty?
            body[:verifiedPhone] = verified_phone unless verified_phone.nil? || !verified_phone.empty?
            body[:inviteUrl] = invite_url unless invite_url.nil? || !invite_url.empty?
            body[:sendMail] = send_mail unless send_mail.nil? || !send_mail.empty?
            body[:sendSMS] = send_sms unless send_sms.nil? || !send_sms.empty?
            body
          end

          def _compose_update_body(
            login_id: nil,
            email: nil,
            phone: nil,
            display_name: nil,
            given_name: nil,
            middle_name: nil,
            family_name: nil,
            role_names: nil,
            user_tenants: nil,
            test: false,
            picture: nil,
            custom_attributes: nil,
            verified_email: nil,
            verified_phone: nil,
            additional_login_ids: nil
          )
            res = {
              loginId: login_id,
              email: email,
              phone: phone,
              displayName: display_name,
              roleNames: role_names,
              userTenants: associated_tenants_to_hash(user_tenants),
              test: test,
              picture: picture,
              customAttributes: custom_attributes,
              additionalLoginIds: additional_login_ids
            }
            res[:verifiedEmail] = verified_email unless verified_email.nil? || !verified_email.empty?
            res[:givenName] = given_name unless given_name.nil?
            res[:middleName] = middle_name unless middle_name.nil?
            res[:familyName] = family_name unless family_name.nil?
            res[:verifiedPhone] = verified_phone unless verified_phone.nil?
            res
          end

          def associated_tenants_to_hash(associated_tenants)
            associated_tenant_list = []
            associated_tenants.each do |tenant|
              associated_tenant_list.append(
                {
                  "tenantId": tenant['tenant_id'],
                  "roleNames": tenant['roles']
                }
              )
            end
          end
        end
      end
    end
  end
end
