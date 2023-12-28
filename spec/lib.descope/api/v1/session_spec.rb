# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Session do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Session)
    dummy_instance.extend(Descope::Mixins::Common::EndpointsV1)
    @instance = dummy_instance
  end

  context '.token_validation_v1'  do
    it 'is expected to respond to token validation v1' do
      expect(@instance).to respond_to(:token_validation_v1)
    end

    it 'is expected to get v1 public key' do
      project_id = 'project123'
      expect(@instance).to receive(:get).with(
        "#{Descope::Mixins::Common::EndpointsV1::PUBLIC_KEY_PATH}/#{project_id}"
      )

      expect { @instance.token_validation_v1('project123') }.not_to raise_error
    end
  end

  context '.token_validation_v2'  do
    it 'is expected to respond to token validation v2' do
      expect(@instance).to respond_to(:token_validation_v2)
    end

    it 'is expected to get v2 public key' do
      project_id = 'project123'
      expect(@instance).to receive(:get).with(
        "#{Descope::Mixins::Common::EndpointsV2::PUBLIC_KEY_PATH}/#{project_id}"
      )

      expect { @instance.token_validation_v2('project123') }.not_to raise_error
    end
  end

  context '.refresh_session' do
    it 'is expected to respond to refresh session' do
      expect(@instance).to respond_to(:refresh_session)
    end

    it 'is expected to post refresh session' do
      expect(@instance).to receive(:post).with(REFRESH_TOKEN_PATH)

      expect { @instance.refresh_session }.not_to raise_error
    end
  end

  context '.me' do
    it 'is expected to respond to /me' do
      expect(@instance).to respond_to(:me)
    end

    it 'is expected to get /me' do
      expect(@instance).to receive(:get).with(ME_PATH)

      expect { @instance.me }.not_to raise_error
    end
  end

  context '.sign_out' do
    it 'is expected to respond to sign out' do
      expect(@instance).to respond_to(:sign_out)
    end

    it 'is expected to post sign out' do
      expect(@instance).to receive(:post).with(LOGOUT_PATH)

      expect { @instance.sign_out }.not_to raise_error
    end
  end

  context '.sign_out_all' do
    it 'is expected to respond to sign out all' do
      expect(@instance).to respond_to(:sign_out_all)
    end

    it 'is expected to post sign out all' do
      expect(@instance).to receive(:post).with(LOGOUT_ALL_PATH)

      expect { @instance.sign_out_all }.not_to raise_error
    end
  end

  context '.validate_session' do
    it 'is expected to respond to validate session' do
      expect(@instance).to respond_to(:validate_session)
    end

    it 'is expected to post validate session' do
      expect(@instance).to receive(:post).with(VALIDATE_SESSION_PATH)

      expect { @instance.validate_session }.not_to raise_error
    end
  end
end
