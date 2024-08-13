# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::SSOApplication do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::SSOApplication)
    @instance = dummy_instance
  end

  context('.create_sso_oidc_application') do
    it 'should respond to .create_saml_application' do
      expect(@instance).to respond_to :create_saml_application
    end

    it 'is expected to create SAML application' do
      expect(@instance).to receive(:post).with(
        SSO_APPLICATION_OIDC_CREATE_PATH, {
          id: 'tenant1',
          name: 'test',
          description: 'awesome tenant',
          enabled: true,
          logo: 'https://logo.com',
          loginPageUrl: 'https://dummy.com/login'
        }
      )
      expect do
        @instance.create_sso_oidc_app(
          id: 'tenant1',
          name: 'test',
          description: 'awesome tenant',
          enabled: true,
          logo: 'https://logo.com',
          login_page_url: 'https://dummy.com/login'
        )
      end.not_to raise_error
    end
  end

  context('.create_saml_application') do
    it 'should respond to .create_saml_application' do
      expect(@instance).to respond_to :create_saml_application
    end

    it 'is expected to create SAML application' do
      expect(@instance).to receive(:post).with(
        SSO_APPLICATION_SAML_CREATE_PATH, {
          name: 'test',
          description: 'awesome tenant',
          id: 'tenant1',
          loginPageUrl: 'https://dummy.com/login',
          logo: 'https://logo.com',
          enabled: true,
          useMetadataInfo: true,
          metadataUrl: 'https://dummy.com/metadata',
          entityId: 'ent1234',
          acsUrl: 'https://dummy.com/acs',
          certificate: 'something',
          attributeMapping: [
            {
              'abc': '123'
            }
          ],
          groupsMapping: [
            {
              'abc': '123'
            }
          ],
          acsAllowedCallbacks: true,
          subjectNameIdType: 'test',
          subjectNameIdFormat: 'test',
          defaultRelayState: 'test',
          forceAuthentication: true,
          logoutRedirectUrl: 'https://dummy.com/logout'
        }
      )
      expect do
        @instance.create_saml_application(
          name: 'test',
          login_page_url: 'https://dummy.com/login',
          id: 'tenant1',
          description: 'awesome tenant',
          logo: 'https://logo.com',
          enabled: true,
          use_metadata_info: true,
          metadata_url: 'https://dummy.com/metadata',
          entity_id: 'ent1234',
          acs_url: 'https://dummy.com/acs',
          certificate: 'something',
          attribute_mapping: [
            {
              'abc': '123'
            }
          ],
          groups_mapping: [
            {
              'abc': '123'
            }
          ],
          acs_allowed_callbacks: true,
          subject_name_id_type: 'test',
          subject_name_id_format: 'test',
          default_relay_state: 'test',
          force_authentication: true,
          logout_redirect_url: 'https://dummy.com/logout'
        )
      end.not_to raise_error
    end

    it 'is expected to raise error if metadata_url is empty' do
      expect do
        @instance.create_saml_application(
          name: 'test',
          login_page_url: 'https://dummy.com/login',
          id: 'tenant1',
          description: 'awesome tenant',
          logo: 'https://logo.com',
          enabled: true,
          use_metadata_info: true,
          entity_id: 'ent1234',
          acs_url: 'https://dummy.com/acs',
          certificate: 'something',
          attribute_mapping: [
            {
              'abc': '123'
            }
          ],
          groups_mapping: [
            {
              'abc': '123'
            }
          ],
          acs_allowed_callbacks: true,
          subject_name_id_type: 'test',
          subject_name_id_format: 'test',
          default_relay_state: 'test',
          force_authentication: true,
          logout_redirect_url: 'https://dummy.com/logout'
        )
      end.to raise_error(Descope::ArgumentException, 'metadata_url argument must be set')
    end
  end

  it 'is expected to raise error if entity_id acs_url and certificate arguments are missing' do
    expect do
      @instance.create_saml_application(
        name: 'test',
        login_page_url: 'https://dummy.com/login',
        id: 'tenant1',
        description: 'awesome tenant',
        logo: 'https://logo.com',
        enabled: true,
        attribute_mapping: [
          {
            'abc': '123'
          }
        ],
        groups_mapping: [
          {
            'abc': '123'
          }
        ],
        acs_allowed_callbacks: true,
        subject_name_id_type: 'test',
        subject_name_id_format: 'test',
        default_relay_state: 'test',
        force_authentication: true,
        logout_redirect_url: 'https://dummy.com/logout'
      )
    end.to raise_error(Descope::ArgumentException, 'entity_id, acs_url, certificate arguments must be set')
  end

  it 'is expected to update sso oidc application' do
    expect(@instance).to receive(:post).with(
      SSO_APPLICATION_OIDC_UPDATE_PATH, {
        id: 'tenant1',
        name: 'test',
        description: 'awesome tenant',
        enabled: true,
        logo: 'https://logo.com',
        loginPageUrl: 'https://dummy.com/login'
      }
    )
    expect do
      @instance.update_sso_oidc_app(
        id: 'tenant1',
        name: 'test',
        description: 'awesome tenant',
        enabled: true,
        logo: 'https://logo.com',
        login_page_url: 'https://dummy.com/login'
      )
    end.not_to raise_error
  end

  it 'is expected to delete sso app' do
    expect(@instance).to receive(:delete).with(
      SSO_APPLICATION_DELETE_PATH, { id: 'tenant1' }
    )
    expect { @instance.delete_sso_app('tenant1') }.not_to raise_error
  end

  it 'is expected to load sso app' do
    expect(@instance).to receive(:get).with(
      SSO_APPLICATION_LOAD_PATH, { id: 'tenant1' }
    )
    expect { @instance.load_sso_app('tenant1') }.not_to raise_error
  end

  it 'is expected to load all sso apps' do
    expect(@instance).to receive(:get).with(
      SSO_APPLICATION_LOAD_ALL_PATH, {}
    )
    expect { @instance.load_all_sso_apps }.not_to raise_error
  end
end
