# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Mgmt::User do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Mgmt::User)
    @instance = dummy_instance
  end

  context '.load_user' do
    it 'is expected to respond to a user_load method' do
      expect(@instance).to respond_to(:load_user)
    end

    it 'is expected to get /v1/mgmt/user' do
      allow(@instance).to receive(:get).with(
        '/v1/mgmt/user', {
          login_id: nil,
          user_id: nil
        }
      )
      expect { @instance.load_user }.to raise_error(Descope::MissingLoginOrUserId)
    end

    it 'is expected to get user details by login_id only' do
      request_params = {
        loginId: 'dummy_login_id'
      }
      expect(@instance).to receive(:get).with('/v1/mgmt/user', params: request_params)
      expect { @instance.load_user(login_id: 'dummy_login_id') }.not_to raise_error
    end

    it 'is expected to get user details by user_id only' do
      request_params = {
        userId: 'dummy_user_id'
      }
      expect(@instance).to receive(:get).with('/v1/mgmt/user', params: request_params)
      expect { @instance.load_user(user_id: 'dummy_user_id') }.not_to raise_error
    end
  end
end
