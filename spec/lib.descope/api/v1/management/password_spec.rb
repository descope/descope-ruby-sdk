# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Password do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Password)
    @instance = dummy_instance
  end

  context '.get_password_settings' do
    it 'should get password settings' do
      expect(@instance).to receive(:get).with('/v1/mgmt/password/settings', { tenantId: 'tenant_id' })
      @instance.get_password_settings('tenant_id')
    end
  end

  context '.update_password_settings' do
    it 'should update password settings' do
      expect(@instance).to receive(:post).with('/v1/mgmt/password/settings', { 'minLength' => 10 })
      @instance.update_password_settings({ min_length: 10 })
    end
  end
end
