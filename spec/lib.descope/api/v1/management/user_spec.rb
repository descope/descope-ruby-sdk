# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::User do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::User)
    @instance = dummy_instance
  end

  context '.create_user_and_test_user' do
    it 'is expected to respond to a user create method' do
      expect(@instance).to respond_to(:create_user)
      expect(@instance).to respond_to(:create_test_user)
    end

    user_tenants_args = [
      {
        tenant_id: 'tenant1'
      },
      {
        tenant_id: 'tenant2',
        role_names: %w[role1 role2]
      }
    ]

    params = {
      loginId: 'name@mail.com',
      email: 'name@mail.com',
      phone: '+1-212-669-2542',
      name: 'name',
      givenName: 'name',
      familyName: 'Ruby SDK',
      userTenants: associated_tenants_to_hash_array(user_tenants_args),
      test: false,
      picture: 'https://www.example.com/picture.png',
      customAttributes: { 'attr1' => 'value1', 'attr2' => 'value2' },
      additionalIdentifiers: %w[id-1 id-2],
      password: 's3cr3t',
      ssoAppIds: %w[app1 app2],
      invite: false
    }

    args = {
      login_id: 'name@mail.com',
      email: 'name@mail.com',
      phone: '+1-212-669-2542',
      name: 'name',
      given_name: 'name',
      family_name: 'Ruby SDK',
      user_tenants: user_tenants_args,
      picture: 'https://www.example.com/picture.png',
      custom_attributes: { 'attr1' => 'value1', 'attr2' => 'value2' },
      additional_identifiers: %w[id-1 id-2],
      password: 's3cr3t',
      sso_app_ids: %w[app1 app2]
    }

    it 'is expected to create a user with user data' do
      expect(@instance).to receive(:post).with(USER_CREATE_PATH, params)

      expect do
        @instance.create_user(**args)
      end.not_to raise_error
    end

    it 'is expected to create a test user with user data' do
      params[:test] = true
      expect(@instance).to receive(:post).with(TEST_USER_CREATE_PATH, params)

      expect do
        args[:test] = true
        @instance.create_test_user(**args)
      end.not_to raise_error
    end
  end

  context '.create_batch_users' do
    it 'is expected to respond to a batch user create method' do
      expect(@instance).to respond_to(:create_batch_users)
    end

    it "is expected to post #{USER_CREATE_BATCH_PATH} with user data" do
      users_input = [
        { 'login_id': 'first@mail.com', 'email': 'first@mail.com' },
        { 'login_id': 'second@mail.com', 'email': 'second@mail.com' },
        { 'login_id': 'third@mail.com', 'email': 'third@mail.com' }
      ]

      users_params = {
        users: [
          {
            loginId: 'first@mail.com', email: 'first@mail.com', test: false, invite: false
          },
          {
            loginId: 'second@mail.com', email: 'second@mail.com', test: false, invite: false
          },
          {
            loginId: 'third@mail.com', email: 'third@mail.com', test: false, invite: false
          }
        ]
      }
      expect(@instance).to receive(:post).with(
        USER_CREATE_BATCH_PATH, users_params
      )

      expect do
        @instance.create_batch_users(users_input)
      end.not_to raise_error
    end
  end

  context '.invite_user' do
    it 'is expected to respond to a user invite method' do
      expect(@instance).to respond_to(:invite_user)
    end

    it "is expected to post #{USER_CREATE_PATH} with invite true" do
      expect(@instance).to receive(:post).with(
        USER_CREATE_PATH, {
          loginId: 'name@mail.com',
          email: 'name@mail.com',
          test: false,
          invite: true,
          templateId: "tid",
        }
      )

      expect do
        @instance.invite_user(
          login_id: 'name@mail.com',
          email: 'name@mail.com',
          template_id: "tid",
        )
      end.not_to raise_error
    end
  end

  context '.update_user' do
    it 'is expected to respond to a update user method' do
      expect(@instance).to respond_to(:update_user)
    end

    it 'is expected to respond to a user update method' do
      expect(@instance).to receive(:post).with(
        USER_UPDATE_PATH, {
          loginId: 'name@mail.com',
          email: 'name@mail.com',
          givenName: 'mister',
          name: 'something else',
          test: false,
          invite: false
        }
      )

      expect do
        @instance.update_user(
          login_id: 'name@mail.com',
          email: 'name@mail.com',
          given_name: 'mister',
          name: 'something else'
        )
      end.not_to raise_error
    end
  end

  context '.delete_user' do
    it 'is expected to respond to a user delete method' do
      expect(@instance).to respond_to(:delete_user)
    end

    it 'is expected to respond to a user delete method' do
      expect(@instance).to receive(:post).with(
        USER_DELETE_PATH, { loginId: 'name@mail.com' }
      )

      expect do
        @instance.delete_user('name@mail.com')
      end.not_to raise_error
    end
  end

  context '.delete_all_user' do
    it 'is expected to respond to a user delete method' do
      expect(@instance).to receive(:delete).with(USER_DELETE_ALL_TEST_USERS_PATH)

      expect do
        @instance.delete_all_test_users
      end.not_to raise_error
    end
  end

  context '.load_user' do
    it 'is expected to respond to a user load (by login id) method' do
      expect(@instance).to respond_to(:load_user)
    end

    it "is expected to get #{USER_LOAD_PATH} with login_id" do
      expect(@instance).to receive(:get).with(
        USER_LOAD_PATH, { loginId: 'someone' }
      )
      expect { @instance.load_user('someone') }.not_to raise_error
    end
  end

  context '.load_by_user_id' do
    it "is expected to get #{USER_LOAD_PATH} with user_id" do
      allow(@instance).to receive(:get).with(
        USER_LOAD_PATH, { userId: 'ABCD' }
      )
      expect { @instance.load_by_user_id('ABCD') }.not_to raise_error
    end
  end

  context '.logout_user' do
    it 'is expected to respond to a logout user method' do
      expect(@instance).to receive(:post).with(
        USER_LOGOUT_PATH, { loginId: 'name@mail.com' }
      )

      expect do
        @instance.logout_user('name@mail.com')
      end.not_to raise_error
    end

    it 'is expected to respond to a logout user by id method' do
      expect(@instance).to receive(:post).with(
        USER_LOGOUT_PATH, { userId: 'U2ZpARjKAJJmq0fzU2lXNNCGnF4j' }
      )

      expect do
        @instance.logout_user_by_id('U2ZpARjKAJJmq0fzU2lXNNCGnF4j')
      end.not_to raise_error
    end
  end

  context '.search_users' do
    it 'is expected to respond to a search_all method' do
      expect(@instance).to respond_to(:search_all_users)

      tenant_role_ids = { 'tenant1' => ['roleA', 'roleB'] }
      tenant_role_names = { 'tenant1' => ['roleName1', 'roleName2'] }
      expect(@instance).to receive(:post).with(
        USERS_SEARCH_PATH, {
          loginId: 'someone@example.com',
          tenantIds: [],
          roleNames: [],
          limit: 10,
          page: 1,
          ssoAppIds: [],
          ssoOnly: false,
          text: 'some text',
          testUsersOnly: false,
          withTestUser: false,
          tenantRoleIds: {
            'tenant1' => { values: ['roleA', 'roleB'] }
          },
          tenantRoleNames: {
            'tenant1' => { values: ['roleName1', 'roleName2'] }
          }
        }
      )

      expect do
        @instance.search_all_users(
          login_id: 'someone@example.com',
          tenant_ids: [],
          role_names: [],
          text: 'some text',
          limit: 10,
          page: 1,
          sso_app_ids: [],
          test_users_only: false,
          with_test_user: false,
          tenant_role_ids: tenant_role_ids,
          tenant_role_names: tenant_role_names
        )
      end.not_to raise_error
    end
  end

  context '.get_provider_token' do
    it 'is expected to respond to a get_provider_token method' do
      expect(@instance).to respond_to(:get_provider_token)

      expect(@instance).to receive(:get).with(
        USER_GET_PROVIDER_TOKEN, {
          loginId: 'someone@example.com',
          provider: 'google-oauth2'
        }
      )

      expect do
        @instance.get_provider_token(
          login_id: 'someone@example.com',
          provider: 'google-oauth2'
        )
      end.not_to raise_error
    end
  end

  context '.activate' do
    it 'is expected to respond to a activate method' do
      expect(@instance).to respond_to(:activate)

      expect(@instance).to receive(:post).with(
        USER_UPDATE_STATUS_PATH, {
          loginId: 'someone@example.com',
          status: 'enabled'
        }
      )

      expect do
        @instance.activate('someone@example.com')
      end.not_to raise_error
    end
  end

  context '.deactivate' do
    it 'is expected to respond to a activate method' do
      expect(@instance).to respond_to(:activate)

      expect(@instance).to receive(:post).with(
        USER_UPDATE_STATUS_PATH, {
          loginId: 'someone@example.com',
          status: 'disabled'
        }
      )

      expect do
        @instance.deactivate('someone@example.com')
      end.not_to raise_error
    end
  end

  context '.update_email' do
    it 'is expected to respond to a update_email method' do
      expect(@instance).to respond_to(:update_email)

      expect(@instance).to receive(:post).with(
        USER_UPDATE_EMAIL_PATH, {
          loginId: 'someone@example.com',
          email: 'tester@test.com',
          verified: true
        }
      )

      expect do
        @instance.update_email(
          login_id: 'someone@example.com',
          email: 'tester@test.com',
          verified: true
        )
      end.not_to raise_error
    end
  end

  context '.update_phone' do
    it 'is expected to respond to a update_phone method' do
      expect(@instance).to respond_to(:update_phone)

      expect(@instance).to receive(:post).with(
        USER_UPDATE_PHONE_PATH, {
          loginId: 'someone@example.com',
          phone: '1234567890',
          verified: true
        }
      )

      expect do
        @instance.update_phone(
          login_id: 'someone@example.com',
          phone: '1234567890',
          verified: true
        )
      end.not_to raise_error
    end
  end

  context '.update_display_name' do
    it 'is expected to respond to a update_display_name method' do
      expect(@instance).to respond_to(:update_display_name)

      expect(@instance).to receive(:post).with(
        USER_UPDATE_NAME_PATH, {
          loginId: 'someone@example.com',
          name: 'some guy',
          givenName: 'some',
          familyName: 'guy',
          middleName: 'middle'
        }
      )

      expect do
        @instance.update_display_name(
          login_id: 'someone@example.com',
          name: 'some guy',
          given_name: 'some',
          family_name: 'guy',
          middle_name: 'middle'
        )
      end.not_to raise_error
    end
  end

  context '.update_picture' do
    it 'is expected to respond to a update_picture method' do
      expect(@instance).to respond_to(:update_picture)

      expect(@instance).to receive(:post).with(
        USER_UPDATE_PICTURE_PATH, {
          loginId: 'someone@example.com',
          picture: 'https://www.example.com/picture.png'
        }
      )

      expect do
        @instance.update_picture(
          login_id: 'someone@example.com',
          picture: 'https://www.example.com/picture.png'
        )
      end.not_to raise_error
    end
  end

  context '.update_custom_attribute' do
    it 'is expected to respond to a update_custom_attribute method' do
      expect(@instance).to respond_to(:update_custom_attribute)

      expect(@instance).to receive(:post).with(
        USER_UPDATE_CUSTOM_ATTRIBUTE_PATH, {
          loginId: 'someone@example.com',
          attributeKey: 'OU',
          attributeValue: 'Engineering'
        }
      )

      expect do
        @instance.update_custom_attribute(
          login_id: 'someone@example.com',
          attribute_key: 'OU',
          attribute_value: 'Engineering'
        )
      end.not_to raise_error
    end
  end

  context '.add_roles' do
    it 'is expected to respond to a add_roles method' do
      expect(@instance).to respond_to(:user_add_roles)

      expect(@instance).to receive(:post).with(
        USER_ADD_ROLE_PATH, {
          loginId: 'someone@example.com',
          roleNames: %w[role1 role2],
          tenantId: 'tenant1'
        }
      )

      expect do
        @instance.user_add_roles(
          login_id: 'someone@example.com',
          role_names: %w[role1 role2],
          tenant_id: 'tenant1'
        )
      end.not_to raise_error
    end
  end

  context '.user_remove_roles' do
    it 'is expected to respond to a user_remove_roles method' do
      expect(@instance).to respond_to(:user_remove_roles)

      expect(@instance).to receive(:post).with(
        USER_REMOVE_ROLE_PATH, {
          loginId: 'someone@example.com',
          roleNames: %w[role1 role2],
          tenantId: 'tenant1'
        }
      )

      expect do
        @instance.user_remove_roles(
          login_id: 'someone@example.com',
          role_names: %w[role1 role2],
          tenant_id: 'tenant1'
        )
      end.not_to raise_error
    end
  end

  context '.add_tenant' do
    it 'is expected to respond to a add_tenant method' do
      expect(@instance).to respond_to(:user_add_tenant)

      expect(@instance).to receive(:post).with(
        USER_ADD_TENANT_PATH, {
          loginId: 'someone@example.com',
          tenantId: 'tenant1'
        }
      )

      expect do
        @instance.user_add_tenant(
          login_id: 'someone@example.com',
          tenant_id: 'tenant1'
        )
      end.not_to raise_error
    end
  end

  context '.remove_tenant' do
    it 'is expected to respond to a remove_tenant method' do
      expect(@instance).to respond_to(:user_remove_tenant)

      expect(@instance).to receive(:post).with(
        USER_REMOVE_TENANT_PATH, {
          loginId: 'someone@example.com',
          tenantId: 'tenant1'
        }
      )

      expect do
        @instance.user_remove_tenant(
          login_id: 'someone@example.com',
          tenant_id: 'tenant1'
        )
      end.not_to raise_error
    end
  end

  context '.add_tenant_role' do
    it 'is expected to respond to a add_tenant_role method' do
      expect(@instance).to respond_to(:add_tenant_role)

      expect(@instance).to receive(:post).with(
        USER_ADD_TENANT_PATH, {
          loginId: 'someone@example.com',
          tenantId: 'tenant1',
          roleNames: %w[role1 role2]
        }
      )

      expect do
        @instance.add_tenant_role(
          login_id: 'someone@example.com',
          tenant_id: 'tenant1',
          role_names: %w[role1 role2]
        )
      end.not_to raise_error
    end
  end

  context '.remove_tenant_role' do
    it 'is expected to respond to a remove_tenant_role method' do
      expect(@instance).to respond_to(:user_remove_tenant_roles)

      expect(@instance).to receive(:post).with(
        USER_REMOVE_TENANT_PATH, {
          loginId: 'someone@example.com',
          tenantId: 'tenant1',
          roleNames: %w[role1 role2]
        }
      )

      expect do
        @instance.user_remove_tenant_roles(
          login_id: 'someone@example.com',
          tenant_id: 'tenant1',
          role_names: %w[role1 role2]
        )
      end.not_to raise_error
    end
  end

  context '.set_temporary_password' do
    it 'is expected to respond to a set_temporary_password method' do
      expect(@instance).to respond_to(:set_temporary_password)

      expect(@instance).to receive(:post).with(
        USER_SET_TEMPORARY_PASSWORD_PATH, {
          loginId: 'someone@example.com',
          password: 's3cr3t'
        }
      )

      expect do
        @instance.set_temporary_password(
          login_id: 'someone@example.com',
          password: 's3cr3t'
        )
      end.not_to raise_error
    end
  end

  context '.set_active_password' do
    it 'is expected to respond to a set_active_password method' do
      expect(@instance).to respond_to(:set_active_password)

      expect(@instance).to receive(:post).with(
        USER_SET_ACTIVE_PASSWORD_PATH, {
          loginId: 'someone@example.com',
          password: 's3cr3t'
        }
      )

      expect do
        @instance.set_active_password(
          login_id: 'someone@example.com',
          password: 's3cr3t'
        )
      end.not_to raise_error
    end
  end

  context '.set_password' do
    it 'is expected to respond to a set_password method' do
      expect(@instance).to respond_to(:set_password)

      expect(@instance).to receive(:post).with(
        USER_SET_PASSWORD_PATH, {
          loginId: 'someone@example.com',
          password: 's3cr3t'
        }
      )

      expect do
        @instance.set_password(
          login_id: 'someone@example.com',
          password: 's3cr3t'
        )
      end.not_to raise_error
    end
  end

  context '.expire_password' do
    it 'is expected to respond to a expire_password method' do
      expect(@instance).to respond_to(:expire_password)

      expect(@instance).to receive(:post).with(
        USER_EXPIRE_PASSWORD_PATH, { loginId: 'someone@example.com' }
      )

      expect { @instance.expire_password('someone@example.com') }.not_to raise_error
    end
  end

  context '.generate_otp_for_test' do
    it 'is expected to respond to a generate_otp_for_test method' do
      expect(@instance).to respond_to(:generate_otp_for_test_user)

      expect(@instance).to receive(:post).with(
        USER_GENERATE_OTP_FOR_TEST_PATH, {
          loginId: 'someone@example.com',
          deliveryMethod: 'email'
        }
      )

      expect do
        @instance.generate_otp_for_test_user(
          method: DeliveryMethod::EMAIL,
          login_id: 'someone@example.com'
        )
      end.not_to raise_error
    end
  end

  context '.generate_enchanted_link_for_test' do
    it 'is expected to respond to a generate_enchanted_link_for_test method' do
      expect(@instance).to respond_to(:generate_enchanted_link_for_test_user)

      expect(@instance).to receive(:post).with(
        USER_GENERATE_ENCHANTED_LINK_FOR_TEST_PATH, {
          loginId: 'someone@example.com',
          URI: 'https://www.example.com'
        }
      )

      expect do
        @instance.generate_enchanted_link_for_test_user(
          login_id: 'someone@example.com',
          uri: 'https://www.example.com'
        )
      end.not_to raise_error
    end
  end

  context '.update_jwt' do
    it 'is expected to respond to a update_jwt method' do
      expect(@instance).to respond_to(:update_jwt)

      expect(@instance).to receive(:post).with(
        UPDATE_JWT_PATH, {
          jwt: 'eyJ3abcde12345',
          customClaims: { 'claim1' => 'value1', 'claim2' => 'value2' }
        }
      )

      expect do
        @instance.update_jwt(
          jwt: 'eyJ3abcde12345',
          custom_claims: { 'claim1' => 'value1', 'claim2' => 'value2' }
        )
      end.not_to raise_error
    end
  end

  context '.generate_embedded_link' do
    it 'is expected to respond to generate_embedded_link' do
      expect(@instance).to respond_to(:generate_embedded_link)
    end

    it 'is expected to generate embedded link' do
      request_params = {
        loginId: 'test',
        customClaims: { 'abc': '123' }
      }

      expect(@instance).to receive(:post).with(
        USER_GENERATE_EMBEDDED_LINK_PATH,
        request_params
      )

      expect do
        @instance.generate_embedded_link(
          login_id: 'test',
          custom_claims: { 'abc': '123' }
        )
      end.not_to raise_error
    end
  end

  context '.patch_user' do
    it 'is expected to respond to a patch user method' do
      expect(@instance).to respond_to(:patch_user)
    end

    it 'is expected to respond to a user patch method' do
      expect(@instance).to receive(:patch).with(
        USER_PATCH_PATH, {
          loginId: 'name@mail.com',
          email: 'name@mail.com',
          givenName: 'mister',
          name: 'something else',
          test: false,
          invite: false
        }
      )

      expect do
        @instance.patch_user(
          login_id: 'name@mail.com',
          email: 'name@mail.com',
          given_name: 'mister',
          name: 'something else'
        )
      end.not_to raise_error
    end
  end

  context '.search_all_test_users' do
    it 'is expected to respond to a search_all_test_users method' do
      expect(@instance).to respond_to(:search_all_test_users)

      tenant_role_ids = { 'tenant1' => ['roleA', 'roleB'] }
      tenant_role_names = { 'tenant1' => ['roleName1', 'roleName2'] }
      expect(@instance).to receive(:post).with(
        TEST_USERS_SEARCH_PATH, {
          tenantIds: %w[t1 t2],
          roleNames: %w[r1 r2],
          limit: 0,
          page: 0,
          testUsersOnly: true,
          withTestUser: true,
          tenantRoleIds: {
            'tenant1' => { values: ['roleA', 'roleB'] }
          },
          tenantRoleNames: {
            'tenant1' => { values: ['roleName1', 'roleName2'] }
          }
        }
      )

      expect do
        @instance.search_all_test_users(
          tenant_ids: %w[t1 t2],
          role_names: %w[r1 r2],
          tenant_role_ids: tenant_role_ids,
          tenant_role_names: tenant_role_names
        )
      end.not_to raise_error
    end
  end
end
