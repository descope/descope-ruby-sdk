# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::EnhancedLink do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::EnhancedLink)
    @instance = dummy_instance
  end

  context '.sign_in' do
    it 'is expected to respond to sign in' do
      expect(@instance).to respond_to(:enchanted_link_sign_in)
    end

    it 'is expected to sign in with enchanted link' do
      request_params = {
        loginId: 'test',
        URI: 'https://some-uri/email',
        loginOptions: { 'abc': '123' }
      }
      expect(@instance).to receive(:post).with(
        compose_signin_uri,
        request_params,
        nil,
        'refresh_token'
      )

      expect do
        @instance.enchanted_link_sign_in(
          login_id: 'test',
          uri: 'https://some-uri/email',
          login_options: { 'abc': '123' },
          refresh_token: 'refresh_token'
        )
      end.not_to raise_error
    end
  end
end
