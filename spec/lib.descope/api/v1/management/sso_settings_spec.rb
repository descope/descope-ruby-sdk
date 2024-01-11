# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::SSOSettings do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::SSOSettings)
    @instance = dummy_instance
  end

  context '.get_sso_settings' do
    it 'should respond to .get_sso_settings' do
      expect(@instance).to respond_to :get_sso_settings
    end

    it 'is expected to get SSO settings' do
      expect(@instance).to receive(:get).with(
        SSO_SETTINGS_PATH, { tenantId: '123' }
      )
      expect { @instance.get_sso_settings('123') }.not_to raise_error
    end
  end

  context '.delete_sso_settings' do
    it 'should respond to .delete_sso_settings' do
      expect(@instance).to respond_to :delete_sso_settings
    end

    it 'is expected to delete SSO settings' do
      expect(@instance).to receive(:delete).with(
        SSO_SETTINGS_PATH, { tenantId: '123' }
      )
      expect { @instance.delete_sso_settings('123') }.not_to raise_error
    end

    context '.configure_sso_oidc_settings' do
      it 'should respond to .configure_sso_oidc' do
        expect(@instance).to respond_to :configure_sso_oidc
      end

      it 'is expected to configure SSO settings' do
        expect(@instance).to receive(:post).with(
          SSO_OIDC_PATH, {
            tenantId: '123',
            settings: {
              name: 'test',
              clientId: 'test',
              scope: ['test'],
              userAttrMapping: {
                loginId: 'test',
                username: 'test',
                name: 'test'
              },
              callbackDomain: 'test'
            },
            redirectUrl: 'test',
            domain: 'test'
          }
        )
        expect do
          @instance.configure_sso_oidc(
            tenant_id: '123',
            settings: {
              name: 'test',
              client_id: 'test',
              scope: ['test'],
              user_attr_mapping: {
                login_id: 'test',
                username: 'test',
                name: 'test'
              },
              callback_domain: 'test'
            },
            redirect_url: 'test',
            domain: 'test'
          )
        end.not_to raise_error
      end
    end
  end
end
