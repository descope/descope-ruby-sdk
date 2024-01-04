# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Password do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Api::V1::Auth::Password)
    @instance = dummy_instance
  end

  context '.sign_up' do
    it 'is expected to respond to sign up' do
      expect(@instance).to respond_to(:password_sign_up)
    end

    it 'is expected to sign up with password' do
      expect(@instance).to receive(:post).with(
        SIGN_UP_PASSWORD_PATH, { loginId: 'test', password: 's3cr3t', user: 'admin' }
      )

      expect { @instance.password_sign_up(login_id: 'test', password: 's3cr3t', user: 'admin') }.not_to raise_error
    end
  end

  context '.sign_in' do
    it 'is expected to respond to sign in' do
      expect(@instance).to respond_to(:password_sign_in)
    end

    it 'is expected to sign in with password' do
      expect(@instance).to receive(:post).with(
        SIGN_IN_PASSWORD_PATH, { loginId: 'test', password: 's3cr3t', ssoAppId: nil }
      )
      # stub the jwt_get_unverified_header method to return the kid of the public key created above
      allow(@instance).to receive(:generate_jwt_response).and_return({})
      expect { @instance.password_sign_in(login_id: 'test', password: 's3cr3t') }.not_to raise_error
    end
  end

  context '.password_replace' do
    it 'is expected to respond to password replace' do
      expect(@instance).to respond_to(:password_replace)
    end

    it 'is expected to replace password' do
      expect(@instance).to receive(:post).with(
        REPLACE_PASSWORD_PATH, { loginId: 'test', oldPassword: 's3cr3t', newPassword: 's3cr3t1' }
      )

      expect do
        @instance.password_replace(
          login_id: 'test', old_password: 's3cr3t', new_password: 's3cr3t1'
        )
      end.not_to raise_error
    end
  end

  context '.password_update' do
    it 'is expected to respond to password update' do
      expect(@instance).to respond_to(:password_update)
    end

    it 'is expected to update password' do
      expect(@instance).to receive(:post).with(
        UPDATE_PASSWORD_PATH, { loginId: 'test', newPassword: 's3cr3t1' }, {}, 'refresh_token'
      )

      expect do
        @instance.password_update(
          login_id: 'test', new_password: 's3cr3t1', refresh_token: 'refresh_token'
        )
      end.not_to raise_error
    end
  end

  context '.get_password_policy' do
    it 'is expected to respond to get password policy' do
      expect(@instance).to respond_to(:get_password_policy)
    end

    it 'is expected to get password policy' do
      expect(@instance).to receive(:get).with(
        PASSWORD_POLICY_PATH, {}, {}, nil
      )

      expect do
        @instance.get_password_policy
      end.not_to raise_error
    end
  end

  context '.password_reset' do
    it 'is expected to respond to password reset' do
      expect(@instance).to respond_to(:password_reset)
    end

    it 'is expected to reset password' do
      expect(@instance).to receive(:post).with(
        SEND_RESET_PASSWORD_PATH, { loginId: 'test', redirectUrl: 'https://www.google.com', providerId: 'test', templateId: 'test' }
      )

      expect do
        @instance.password_reset(
          login_id: 'test', redirect_url: 'https://www.google.com', provider_id: 'test', template_id: 'test'
        )
      end.not_to raise_error
    end
  end
end
