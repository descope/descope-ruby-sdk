# frozen_string_literal: true

module Descope
  module Api
    module V1
      module Management
        # Management API calls
        module User
          # Create a new user, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/CreateUser/
          # Once the user is created, the user can then login utilizing any sign-in api supported. This will then switch the user from invited to active.
          def create_user(**args)
            logger.debug("Creating user with args: #{args}")
            user_create(**args)
          end

          # Batch Create Users, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/CreateUsers/
          def create_batch_users(users = [])
            users_params = []
            users.each do |user|
              users_params.append(user_create(**user.merge(skip_create: true)))
            end
            path = Common::USER_CREATE_BATCH_PATH
            request_params = {
              users: users_params
            }
            post(path, request_params)
          end

          # Create a new test user.
          # The login_id is required and will determine what the user will use to sign in.
          # Make sure the login id is unique for test. All other fields are optional.
          # @see https://docs.descope.com/api/testusermanagement/
          # Test User Management:
          # 1. Create test Users
          # 2. Generate OTP (sms/email) for test users
          # 3. Generate Magic Link (sms/email) for test users
          # 4. Generate Enchanted Link (email) for test users
          # 5. Delete Test Users
          def create_test_user(**args)
            args[:test] = true
            user_create(**args)
          end

          # Create a new user and invite them via an email message.
          #
          #         Functions exactly the same as the `create` function with the additional invitation
          #             behavior. See the documentation above for the general creation behavior.
          #
          #         IMPORTANT: Since the invitation is sent by email, make sure either
          #             the email is explicitly set, or the login_id itself is an email address.
          #             You must configure the invitation URL in the Descope console prior to
          #             calling the method.
          def invite_user(**args)
            args[:invite] = true
            user_create(**args)
          end

          # Updates a user's details, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUser/
          def update_user(
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
            additional_login_ids: nil
          )
            role_names ||= []
            user_tenants ||= []
            path = Common::USER_UPDATE_PATH
            request_params = user_compose_update_body(
              login_id:,
              email:,
              phone:,
              display_name:,
              given_name:,
              middle_name:,
              family_name:,
              role_names:,
              user_tenants:,
              picture:,
              custom_attributes:,
              verified_email:,
              verified_phone:,
              additional_login_ids:
            )
            post(path, request_params)
          end

          # Delete a user, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/DeleteUser/
          def delete_user(login_id = nil)
            validate_login_id(login_id)
            path = Common::USER_DELETE_PATH
            request_params = {
              loginId: login_id
            }
            post(path, request_params)
          end

          def delete_all_test_users
            path = Common::USER_DELETE_ALL_TEST_USERS_PATH
            delete(path)
          end

          # Load a user's data, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/LoadUser/
          def load_user(login_id)
            logger.debug("Loading user with login_id: #{login_id}")
            # Retrieve user information based on the provided Login ID
            validate_login_id(login_id)

            request_params = {
              loginId: login_id
            }
            path = Common::USER_LOAD_PATH
            get(path, request_params)
          end

          # Load a user's data, using a valid management key by user id.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/LoadUser/
          def load_by_user_id(user_id)
            # Retrieve user information based on the provided user ID
            # The user ID can be found on the user's JWT.
            validate_user_id(user_id)

            path = Common::USER_LOAD_PATH
            request_params = {
              userId: user_id
            }
            get(path, request_params)
          end

          # Log a user out of all sessions, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/LogoutAllUserDevices/
          def logout_user(login_id)
            validate_login_id(login_id)
            path = Common::USER_LOGOUT_PATH
            request_params = {
              loginId: login_id
            }
            post(path, request_params)
          end

          def logout_user_by_id(user_id)
            validate_user_id(user_id)
            path = Common::USER_LOGOUT_PATH
            request_params = {
              userId: user_id
            }
            post(path, request_params)
          end

          # Search for users, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/SearchUsers/
          def search_all_users(
            login_id: nil,
            tenant_ids: [],
            role_names: [],
            text: nil,
            limit: 0,
            page: 0,
            sso_only: false,
            test_users_only: false,
            with_test_user: false,
            custom_attributes: {},
            statuses: [],
            emails: [],
            phones: [],
            sso_app_ids: []
          )
            body = {
              loginId: login_id,
              tenantIds: tenant_ids,
              roleNames: role_names,
              ssoOnly: sso_only,
              limit:,
              page:,
              text:,
              testUsersOnly: test_users_only,
              withTestUser: with_test_user,
              ssoAppIds: sso_app_ids,
            }
            body[:statuses] = statuses unless statuses.empty?
            body[:emails] = emails unless emails.empty?
            body[:phones] = phones unless phones.empty?
            body[:customAttributes] = custom_attributes unless custom_attributes.empty?
            body[:limit] = limit unless limit.zero?
            body[:page] = page unless page.zero?
            body[:text] = text unless text.nil?
            body[:testUsersOnly] = test_users_only unless test_users_only.nil?
            body[:withTestUser] = with_test_user unless with_test_user.nil?
            body[:ssoOnly] = sso_only unless sso_only.nil?
            body[:ssoAppIds] = sso_app_ids unless sso_app_ids.empty?
            body[:tenantIds] = tenant_ids unless tenant_ids.empty?
            body[:roleNames] = role_names unless role_names.empty?
            post(Common::USERS_SEARCH_PATH, body)
          end

          # Get an existing user's provider token, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/GetUserProviderToken/
          def get_provider_token(login_id: nil, provider: nil)
            path = Common::USER_GET_PROVIDER_TOKEN
            request_params = {
              loginId: login_id,
              provider: provider
            }
            get(path, request_params)
          end

          # Updates an existing user's status, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUserStatus/
          def activate(login_id)
            validate_login_id(login_id)
            path = Common::USER_UPDATE_STATUS_PATH
            request_params = {
              loginId: login_id,
              status: 'enabled'
            }
            post(path, request_params)
          end

          def deactivate(login_id)
            validate_login_id(login_id)
            path = Common::USER_UPDATE_STATUS_PATH
            request_params = {
              loginId: login_id,
              status: 'disabled'
            }
            post(path, request_params)
          end

          # Updates an existing user's login ID, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUserLoginID/
          def update_login_id(login_id: nil, new_login_id: nil)
            validate_login_id(login_id)
            path = Common::USER_UPDATE_LOGIN_ID_PATH
            request_params = {
              loginId: login_id,
              newLoginId: new_login_id
            }
            post(path, request_params)
          end

          # Updates an existing user's email, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUserEmail/
          def update_email(login_id: nil, email: nil, verified: true)
            logger.debug("Updating user's email with login_id: #{login_id} to #{email} verified: #{verified}")
            path = Common::USER_UPDATE_EMAIL_PATH
            request_params = {
              loginId: login_id,
              email:,
              verified:
            }
            post(path, request_params)
          end

          # Updates an existing user's phone number, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUserPhone/
          def update_phone(login_id: nil, phone: nil, verified: true)
            path = Common::USER_UPDATE_PHONE_PATH
            request_params = {
              loginId: login_id,
              phone:,
              verified:
            }
            post(path, request_params)
          end

          # Updates an existing user's display name, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUserDisplayName/
          def update_display_name(
            login_id: nil,
            display_name: nil,
            given_name: nil,
            middle_name: nil,
            family_name: nil
          )
            body = { loginId: login_id }
            body[:displayName] = display_name unless display_name.nil?
            body[:givenName] = given_name unless given_name.nil?
            body[:middleName] = middle_name unless middle_name.nil?
            body[:familyName] = family_name unless family_name.nil?
            post(Common::USER_UPDATE_NAME_PATH, body)
          end

          # Update an existing user's profile picture, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUserPicture/
          def update_picture(login_id: nil, picture: nil)
            body = {
              loginId: login_id,
              picture: picture
            }
            post(Common::USER_UPDATE_PICTURE_PATH, body)
          end

          # Update an existing user's custom attributes, using a valid management key.
          # @see https://docs.descope.com/api/openapi/usermanagement/operation/UpdateUserCustomAttribute/
          def update_custom_attribute(login_id: nil, attribute_key: nil, attribute_value: nil)
            logger.debug("Updating user's custom attribute with login_id: #{login_id} to #{attribute_key}: #{attribute_value}")
            body = {
              loginId: login_id,
              attributeKey: attribute_key,
              attributeValue: attribute_value
            }
            post(Common::USER_UPDATE_CUSTOM_ATTRIBUTE_PATH, body)
          end

          def update_jwt(jwt: nil, custom_claims: nil)
            body = {
              jwt: jwt,
              customClaims: custom_claims,
            }
            post(Common::UPDATE_JWT_PATH, body)
          end

          #
          def add_roles(login_id: nil, role_names: [])
            body = {
              loginId: login_id,
              roleNames: role_names
            }
            post(Common::USER_ADD_ROLE_PATH, body)
          end

          def remove_roles(login_id: nil, role_names: [])
            body = {
              loginId: login_id,
              roleNames: role_names
            }
            post(Common::USER_REMOVE_ROLE_PATH, body)
          end

          def add_tenant(login_id: nil, tenant_id: nil)
            body = {
              loginId: login_id,
              tenantId: tenant_id
            }
            post(Common::USER_ADD_TENANT_PATH, body)
          end

          def remove_tenant(login_id: nil, tenant_id: nil)
            body = {
              loginId: login_id,
              tenantId: tenant_id
            }
            post(Common::USER_REMOVE_TENANT_PATH, body)
          end

          def add_tenant_role(login_id: nil, tenant_id: nil, role_names: [])
            body = {
              loginId: login_id,
              tenantId: tenant_id,
              roleNames: role_names
            }
            post(Common::USER_ADD_TENANT_PATH, body)
          end

          def remove_tenant_roles(login_id: nil, tenant_id: nil, role_names: [])
            body = {
              loginId: login_id,
              tenantId: tenant_id,
              roleNames: role_names
            }
            post(Common::USER_REMOVE_TENANT_PATH, body)
          end

          def set_password(login_id: nil, password: nil)
            body = {
              loginId: login_id,
              password:
            }
            post(Common::USER_SET_PASSWORD_PATH, body)
          end

          def expire_password(login_id)
            validate_login_id(login_id)
            body = {
              loginId: login_id
            }
            post(Common::USER_EXPIRE_PASSWORD_PATH, body)
          end

          def generate_otp_for_test_user(method: nil, login_id: nil)
            body = {
              loginId: login_id,
              deliveryMethod: get_method_string(method)
            }
            post(Common::USER_GENERATE_OTP_FOR_TEST_PATH, body)
          end

          def generate_magic_link_for_test_user(method: nil, login_id: nil, uri: nil)
            body = {
              loginId: login_id,
              deliveryMethod: get_method_string(method),
              URI: uri
            }
            post(Common::USER_GENERATE_MAGIC_LINK_FOR_TEST_PATH, body)
          end

          def generate_enchanted_link_for_test_user(login_id: nil, uri: nil)
            body = {
              loginId: login_id,
              URI: uri
            }
            post(Common::USER_GENERATE_ENCHANTED_LINK_FOR_TEST_PATH, body)
          end

          def generate_embedded_link(login_id: nil, custom_claims: nil)
            custom_claims ||= {}
            unless custom_claims.is_a?(Hash)
              raise Descope::ArgumentException.new(
                'Unable to read custom_claims, not a Hash',
                code: 400
              )
            end

            validate_login_id(login_id)
            request_params = {
              loginId: login_id,
              customClaims: custom_claims.to_h
            }
            post(USER_GENERATE_EMBEDDED_LINK_PATH, request_params)
          end

          private

          def user_create(
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
            test: false,
            invite: false,
            additional_login_ids: nil,
            skip_create: false
          )
            role_names ||= []
            user_tenants ||= []
            path = Common::USER_CREATE_PATH
            request_params = user_compose_create_body(
              login_id:,
              email:,
              phone:,
              display_name:,
              given_name:,
              middle_name:,
              family_name:,
              role_names:,
              user_tenants:,
              invite:,
              test:,
              picture:,
              custom_attributes:,
              verified_email:,
              verified_phone:,
              invite_url:,
              send_mail: nil,
              send_sms: nil,
              additional_login_ids:
            )
            return request_params if skip_create

            post(path, request_params)
          end

          def user_compose_create_body(
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
            body = user_compose_update_body(
              login_id:,
              email:,
              phone:,
              display_name:,
              given_name:,
              middle_name:,
              family_name:,
              role_names:,
              user_tenants:,
              test:,
              invite:,
              picture:,
              custom_attributes:,
              additional_login_ids:
            )
            body[:invite] = invite
            body[:verifiedEmail] = verified_email unless verified_email.nil? || !verified_email.empty?
            body[:verifiedPhone] = verified_phone unless verified_phone.nil? || !verified_phone.empty?
            body[:inviteUrl] = invite_url unless invite_url.nil? || !invite_url.empty?
            body[:sendMail] = send_mail unless send_mail.nil? || !send_mail.empty?
            body[:sendSMS] = send_sms unless send_sms.nil? || !send_sms.empty?
            body
          end

          def user_compose_update_body(
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
            invite: false,
            picture: nil,
            custom_attributes: nil,
            verified_email: nil,
            verified_phone: nil,
            additional_login_ids: nil
          )
            body = {
              loginId: login_id,
              email:,
              phone:,
              displayName: display_name,
              roleNames: role_names,
              userTenants: associated_tenants_to_hash_array(user_tenants),
              test:,
              invite:,
              picture:,
              customAttributes: custom_attributes,
              additionalLoginIds: additional_login_ids
            }
            body[:verifiedEmail] = verified_email unless verified_email.nil? || !verified_email.empty?
            body[:givenName] = given_name unless given_name.nil?
            body[:middleName] = middle_name unless middle_name.nil?
            body[:familyName] = family_name unless family_name.nil?
            body[:verifiedPhone] = verified_phone unless verified_phone.nil?
            body
          end
        end
      end
    end
  end
end
