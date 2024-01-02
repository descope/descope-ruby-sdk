# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Session do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::Password)
    @instance = dummy_instance
  end

  context '.sign_up' do
    it 'is expected to respond to sign up' do
      expect(@instance).to respond_to(:sign_up)
    end

    it 'is expected to sign up with password' do
      expect(@instance).to receive(:post).with(
        SIGN_UP_PASSWORD_PATH, { loginId: 'test', password: 's3cr3t', user: 'admin' }
      )

      expect { @instance.sign_up(login_id: 'test', password: 's3cr3t', user: 'admin') }.not_to raise_error
    end
  end

  context '.sign_in' do
    it 'is expected to respond to sign in' do
      expect(@instance).to respond_to(:sign_in)
    end

    it 'is expected to sign in with password' do
      expect(@instance).to receive(:post).with(
        SIGN_IN_PASSWORD_PATH, { loginId: 'test', password: 's3cr3t', ssoAppId: nil }
      )
      # stub the jwt_get_unverified_header method to return the kid of the public key created above
      allow(@instance).to receive(:generate_jwt_response).and_return({})
      expect { @instance.sign_in(login_id: 'test', password: 's3cr3t') }.not_to raise_error
    end
  end
end
