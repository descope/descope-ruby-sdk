# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::User do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::User)
    @instance = dummy_instance
  end

  context '.load' do
    it 'is expected to respond to a user load (by login id) method' do
      expect(@instance).to respond_to(:load)
    end

    it "is expected to get #{USER_LOAD_PATH} with login_id" do
      allow(@instance).to receive(:get).with(
        USER_LOAD_PATH, { login_id: 'someone' }
      )
      expect { @instance.load(login_id: 'someone') }.not_to raise_error(Descope::AuthException)
    end

    it "is expected to raise error on #{USER_LOAD_PATH} without login_id" do
      allow(@instance).to receive(:get).with(USER_LOAD_PATH, nil)
      expect { @instance.load }.to raise_error(Descope::AuthException)
    end
  end

  context '.load_by_user_id' do
    it "is expected to get #{USER_LOAD_PATH} with user_id" do
      allow(@instance).to receive(:get).with(
        USER_LOAD_PATH, { user_id: 'ABCD' }
      )
      expect { @instance.load_by_user_id(user_id: 'ABCD') }.not_to raise_error(Descope::AuthException)
    end

    it "is expected to raise error on #{USER_LOAD_PATH} without user_id" do
      allow(@instance).to receive(:get).with(USER_LOAD_PATH, nil)
      expect { @instance.load_by_user_id }.to raise_error(Descope::AuthException)
    end
  end
end
