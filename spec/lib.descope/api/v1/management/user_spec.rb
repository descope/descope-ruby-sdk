# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::User do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::User)
    @instance = dummy_instance
  end

  context '.load_user' do
    it 'is expected to respond to a user load (by login id) method' do
      expect(@instance).to respond_to(:load_user)
    end

    it "is expected to get #{USER_LOAD_PATH} with login_id" do
      expect(@instance).to receive(:get).with(
        USER_LOAD_PATH, { loginId: 'someone' }
      )
      expect { @instance.load_user(login_id: 'someone') }.not_to raise_error(Descope::ArgumentException)
    end

    it "is expected to raise error on #{USER_LOAD_PATH} without login_id" do
      allow(@instance).to receive(:get).with(USER_LOAD_PATH, nil)
      expect { @instance.load_user }.to raise_error(Descope::ArgumentException)
    end
  end

  context '.load_by_user_id' do
    it "is expected to get #{USER_LOAD_PATH} with user_id" do
      allow(@instance).to receive(:get).with(
        USER_LOAD_PATH, { user_id: 'ABCD' }
      )
      expect { @instance.load_by_user_id(user_id: 'ABCD') }.not_to raise_error(Descope::ArgumentException)
    end

    it "is expected to raise error on #{USER_LOAD_PATH} without user_id" do
      allow(@instance).to receive(:get).with(USER_LOAD_PATH, nil)
      expect { @instance.load_by_user_id }.to raise_error(Descope::ArgumentException)
    end
  end

  context '.create_user' do
    it 'is expected to respond to a user create method' do
      expect(@instance).to respond_to(:create_user)
    end

    it "is expected to post #{USER_CREATE_PATH} with user data" do
      tenant1 = Descope::Api::V1::Management::Common::AssociatedTenant.new(tenant_id: 'tenant1')
      user_tenant1 = {
        "tenantId": tenant1.tenant_id
      }

      tenant2 = Descope::Api::V1::Management::Common::AssociatedTenant.new(
        tenant_id: 'tenant2',
        role_names: %w[role1 role2]
      )
      user_tenant2 = {
        "tenantId": tenant2.tenant_id,
        "roleNames": tenant2.role_names
      }

      expect(@instance).to receive(:post).with(
        USER_CREATE_PATH, {
          loginId: 'name@mail.com',
          email: 'name@mail.com',
          phone: nil,
          displayName: 'name',
          roleNames: [],
          userTenants: [user_tenant1, user_tenant2],
          test: false,
          picture: 'https://www.example.com/picture.png',
          customAttributes: { 'attr1' => 'value1', 'attr2' => 'value2' },
          additionalLoginIds: %w[id-1 id-2],
          invite: false
        }
      )

      expect do
        @instance.create_user(
          login_id: 'name@mail.com',
          email: 'name@mail.com',
          display_name: 'name',
          user_tenants: [user_tenant1, user_tenant2],
          picture: 'https://www.example.com/picture.png',
          custom_attributes: { 'attr1' => 'value1', 'attr2' => 'value2' },
          additional_login_ids: %w[id-1 id-2]
        )
      end.not_to raise_error


    end
  end
end
