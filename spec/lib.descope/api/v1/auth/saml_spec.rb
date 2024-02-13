# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::SAML do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::OAuth)
    @instance = dummy_instance
  end

  context '.saml_start' do
    it 'is expected to respond to saml start' do
      expect(@instance).to respond_to(:saml_sign_in)
    end

    it 'is expected to sign in single sign-on saml' do
      request_params = {
        stepup: false,
        customClaims: { 'abc': '123' },
        mfa: false,
        ssoAppId: 'sso-id'
      }
      formatted_uri = '/v1/auth/saml/authorize?tenant=some-tenant&redirectUrl=https%3A%2F%2Fsome-uri%2Femail&prompt=custom+prompt+%26+needs+to+be+decoded%3A+too'
      expect(@instance).to receive(:post).with(formatted_uri, request_params)

      expect do
        @instance.saml_sign_in(
          tenant: 'some-tenant',
          prompt: 'custom prompt & needs to be decoded: too',
          redirect_url: 'https://some-uri/email',
          stepup: false,
          custom_claims: { 'abc': '123' },
          mfa: false,
          sso_app_id: 'sso-id'
        )
      end.not_to raise_error
    end
  end

  context '.saml_exchange_token' do
    it 'is expected to respond to saml exchange token' do
      expect(@instance).to respond_to(:saml_exchange_token)
    end

    it 'is expected to exchange token' do
      jwt_response = { 'fake': 'response' }
      allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)

      expect(@instance).to receive(:post).with(SAML_EXCHANGE_TOKEN_PATH, { code: '123456' }).and_return(jwt_response)
      expect { @instance.saml_exchange_token('123456') }.not_to raise_error
    end
  end
end
