# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::OAuth do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::OAuth)
    @instance = dummy_instance
  end

  context '.oauth_start' do
    it 'is expected to respond to oauth start' do
      expect(@instance).to respond_to(:oauth_start)
    end

    it 'is expected to start oauth' do
      request_params = {
        stepup: false,
        customClaims: { 'abc': '123' },
        mfa: false,
        ssoAppId: 'sso-id'
      }
      url = "#{OAUTH_START_PATH}?provider=github"
      url += "&redirectUrl=#{CGI.escape('https://some-uri/email')}"
      url += "&prompt=#{CGI.escape('hello and welcome')}"

      expect(@instance).to receive(:post).with(
        url,
        request_params,
        {},
        'refresh_token'
      )

      expect do
        @instance.oauth_start(
          provider: 'github',
          return_url: 'https://some-uri/email',
          prompt: 'hello and welcome',
          login_options: {
            stepup: false,
            custom_claims: { 'abc': '123' },
            mfa: false,
            sso_app_id: 'sso-id'
          },
          refresh_token: 'refresh_token'
        )
      end.not_to raise_error
    end
  end

  context '.oauth_exchange_token' do
    it 'is expected to respond to oauth exchange token' do
      expect(@instance).to respond_to(:oauth_exchange_token)
    end

    it 'is expected to exchange token' do
      request_params = { code: 'some-code' }
      jwt_response = { 'fake': 'response' }
      expect(@instance).to receive(:post).with(OAUTH_EXCHANGE_TOKEN_PATH, request_params).and_return(jwt_response)
      allow(@instance).to receive(:generate_jwt_response).and_return(jwt_response)
      expect { @instance.oauth_exchange_token('some-code') }.not_to raise_error
    end
  end

  context '.oauth_create_redirect_url_for_sign_in_request' do
    it 'is expected to respond to oauth create redirect url for sign in request' do
      expect(@instance).to respond_to(:oauth_create_redirect_url_for_sign_in_request)
    end

    it 'is expected to create redirect url for sign in request' do
      request_params = {
        stepup: true,
        customClaims: { 'abc': '123' },
        mfa: false,
        ssoAppId: 'sso-id'
      }
      expect(@instance).to receive(:post).with(
        OAUTH_CREATE_REDIRECT_URL_FOR_SIGN_IN_REQUEST_PATH,
        request_params
      )
      expect do
        @instance.oauth_create_redirect_url_for_sign_in_request(
          stepup: true,
          custom_claims: { 'abc': '123' },
          sso_app_id: 'sso-id'
        )
      end.not_to raise_error
    end
  end

  context '.oauth_create_redirect_url_for_sign_in_request' do
    it 'is expected to respond to oauth create redirect url for sign in request' do
      expect(@instance).to respond_to(:oauth_create_redirect_url_for_sign_in_request)
    end

    it 'is expected to create redirect url for sign up request' do
      request_params = {
        stepup: false,
        customClaims: { 'abc': '123' },
        mfa: false,
        ssoAppId: 'sso-id'
      }
      expect(@instance).to receive(:post).with(
        OAUTH_CREATE_REDIRECT_URL_FOR_SIGN_UP_REQUEST_PATH,
        request_params
      )
      expect do
        @instance.oauth_create_redirect_url_for_sign_up_request(
          custom_claims: { 'abc': '123' },
          sso_app_id: 'sso-id'
        )
      end.not_to raise_error
    end
  end
end
