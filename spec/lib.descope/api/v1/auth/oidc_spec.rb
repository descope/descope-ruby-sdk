# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::OIDC do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::OIDC)
    @instance = dummy_instance
  end

  context '.oidc_start' do
    it 'is expected to respond to oidc start' do
      expect(@instance).to respond_to(:oidc_start)
    end

    it 'is expected to start oidc' do
      response_type = 'code'
      scope = 'openid'
      client_id = 'client-id'
      state = 'state'
      redirect_url = 'https://some-uri/email'
      code_challenge_method = 'S256'
      code_challenge = 'code-challenge'
      dynamic_val = 'dynamic-val'
      nonce = 'nonce'
      sso_app_id = 'sso-id'
      login_hint = 'login-hint'

      url = @instance.send(:compose_oidc_start_url, response_type, scope, client_id, state, redirect_url,
                           code_challenge_method, code_challenge, dynamic_val, nonce, sso_app_id, login_hint)
      expect(@instance).to receive(:get).with(url)
      expect do
        @instance.oidc_start(
          response_type: 'code',
          scope: 'openid',
          client_id: 'client-id',
          state: 'state',
          redirect_url: 'https://some-uri/email',
          code_challenge_method: 'S256',
          code_challenge: 'code-challenge',
          dynamic_val: 'dynamic-val',
          nonce: 'nonce',
          sso_app_id: 'sso-id',
          login_hint: 'login-hint'
        )
      end.not_to raise_error
    end
  end
end
