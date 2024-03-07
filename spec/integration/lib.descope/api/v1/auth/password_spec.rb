# frozen_string_literal: true

require 'spec_helper'
require 'rotp'

describe Descope::Api::V1::Auth::Password do
  before(:all) do
    @password = SpecUtils.generate_password
    @new_password = SpecUtils.generate_password
    @user = build(:user)
    @client = DescopeClient.new(Configuration.config)
  end

  context 'test password methods' do
    it 'should get password policy' do
      # Get the configured password policy for the project.
      res = @client.get_password_policy
      @client.logger.info("Password policy: #{res}")
    end

    it 'should sign up with password' do
      res = @client.password_sign_up(login_id: @user[:login_id], password: @password, user: @user)
      expect { res }.not_to raise_error
    end

    it 'should sign in with password' do
      res = @client.password_sign_in(login_id: @user[:login_id], password: @password)
      expect { res }.not_to raise_error
    end

    it 'should replace the password' do
      res = @client.password_replace(login_id: @user[:login_id], old_password: @password, new_password: @new_password)
      expect { res }.not_to raise_error
    end

    it 'should login with new password' do
      res = @client.password_sign_in(login_id: @user[:login_id], password: @new_password)
      expect { res }.not_to raise_error
    end
  end
end
