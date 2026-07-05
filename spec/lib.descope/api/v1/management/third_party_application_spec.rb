# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::ThirdPartyApplication do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::ThirdPartyApplication)
    @instance = dummy_instance
  end

  context('.create_application') do
    it 'should respond to .create_application' do
      expect(@instance).to respond_to :create_application
    end

    it 'is expected to create a third party application' do
      expect(@instance).to receive(:post).with(
        THIRD_PARTY_APP_CREATE_PATH, {
          id: 'app1',
          name: 'test',
          description: 'awesome app',
          logo: 'https://logo.com',
          loginPageUrl: 'https://dummy.com/login',
          approvedCallbackUrls: ['https://dummy.com/callback'],
          permissionsScopes: [{ name: 'read' }],
          attributesScopes: [{ name: 'email' }],
          jwtBearerSettings: [{ tenantId: 'tenant1' }],
          customAttributes: { key: 'value' },
          forcePkce: true,
          defaultAudience: 'aud1'
        }
      )
      expect do
        @instance.create_application(
          id: 'app1',
          name: 'test',
          description: 'awesome app',
          logo: 'https://logo.com',
          login_page_url: 'https://dummy.com/login',
          approved_callback_urls: ['https://dummy.com/callback'],
          permissions_scopes: [{ name: 'read' }],
          attributes_scopes: [{ name: 'email' }],
          jwt_bearer_settings: [{ tenantId: 'tenant1' }],
          custom_attributes: { key: 'value' },
          force_pkce: true,
          default_audience: 'aud1'
        )
      end.not_to raise_error
    end
  end

  context('.update_application') do
    it 'should respond to .update_application' do
      expect(@instance).to respond_to :update_application
    end

    it 'is expected to update a third party application' do
      expect(@instance).to receive(:post).with(
        THIRD_PARTY_APP_UPDATE_PATH, {
          id: 'app1',
          name: 'test',
          description: 'awesome app',
          logo: 'https://logo.com',
          loginPageUrl: 'https://dummy.com/login'
        }
      )
      expect do
        @instance.update_application(
          id: 'app1',
          name: 'test',
          description: 'awesome app',
          logo: 'https://logo.com',
          login_page_url: 'https://dummy.com/login'
        )
      end.not_to raise_error
    end
  end

  context('.patch_application') do
    it 'should respond to .patch_application' do
      expect(@instance).to respond_to :patch_application
    end

    it 'is expected to patch a third party application' do
      expect(@instance).to receive(:post).with(
        THIRD_PARTY_APP_PATCH_PATH, {
          id: 'app1',
          name: 'test'
        }
      )
      expect do
        @instance.patch_application(
          id: 'app1',
          name: 'test'
        )
      end.not_to raise_error
    end
  end

  it 'is expected to delete a third party application' do
    expect(@instance).to receive(:post).with(
      THIRD_PARTY_APP_DELETE_PATH, { id: 'app1' }
    )
    expect { @instance.delete_application('app1') }.not_to raise_error
  end

  it 'is expected to load a third party application' do
    expect(@instance).to receive(:get).with(
      THIRD_PARTY_APP_LOAD_PATH, { id: 'app1' }
    )
    expect { @instance.load_application('app1') }.not_to raise_error
  end

  it 'is expected to load all third party applications' do
    expect(@instance).to receive(:get).with(
      THIRD_PARTY_APP_LOAD_ALL_PATH, {}
    )
    expect { @instance.load_all_applications }.not_to raise_error
  end

  it 'is expected to get a third party application secret' do
    expect(@instance).to receive(:get).with(
      THIRD_PARTY_APP_SECRET_PATH, { id: 'app1' }
    )
    expect { @instance.get_application_secret('app1') }.not_to raise_error
  end

  it 'is expected to rotate a third party application secret' do
    expect(@instance).to receive(:post).with(
      THIRD_PARTY_APP_ROTATE_PATH, { id: 'app1' }
    )
    expect { @instance.rotate_application_secret('app1') }.not_to raise_error
  end

  it 'is expected to delete consents' do
    expect(@instance).to receive(:post).with(
      THIRD_PARTY_APP_DELETE_CONSENTS_PATH, {
        consentIds: %w[consent1 consent2],
        appId: 'app1',
        userIds: %w[user1 user2],
        tenantId: 'tenant1'
      }
    )
    expect do
      @instance.delete_consents(
        app_id: 'app1',
        consent_ids: %w[consent1 consent2],
        user_ids: %w[user1 user2],
        tenant_id: 'tenant1'
      )
    end.not_to raise_error
  end

  it 'is expected to delete tenant consents' do
    expect(@instance).to receive(:post).with(
      THIRD_PARTY_APP_DELETE_TENANT_CONSENTS_PATH, {
        consentIds: %w[consent1 consent2],
        appId: 'app1',
        tenantId: 'tenant1'
      }
    )
    expect do
      @instance.delete_tenant_consents(
        app_id: 'app1',
        consent_ids: %w[consent1 consent2],
        tenant_id: 'tenant1'
      )
    end.not_to raise_error
  end
end
