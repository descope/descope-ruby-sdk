# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Audit do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Audit)
    @instance = dummy_instance
  end

  context '.search' do
    let(:mock_response) do
      {
        'audits' => [
          {
            'projectId' => 'abc',
            'userId' => 'abcde',
            'action' => 'get',
            'occurred' => 1,
            'method' => 'post',
            'device' => 'mobile',
            'geo' => 'US',
            'remoteAddress' => '1.2.3.4',
            'externalIds' => [],
            'tenants' => [],
            'data' => {}
          }
        ]
      }
    end

    before do
      allow(@instance).to receive(:post).twice.with(
        AUDIT_SEARCH,
        {
          noTenants: true,
          userIds: %w[user1 user2],
          excludeActions: %w[exclude1 exclude2],
          devices: %w[Bot Mobile Desktop Tablet Unknown],
          methods: %w[otp totp magiclink oauth saml password],
          geos: %w[US IL],
          remoteAddresses: %w[remote1 remote2],
          externalIds: %w[login1 login2],
          tenants: %w[tenant1 tenant2],
          text: 'text123',
          from: 1_234_567_000,
          to: 123_456_789_000
        }
      ).and_return(mock_response)
    end

    it 'should respond to .search' do
      expect(@instance).to respond_to :audit_search
    end

    it 'is expected to search audit trail and get audits' do
      res = nil # define res outside the block
      expect do
        res = @instance.audit_search(
          no_tenants: true,
          user_ids: %w[user1 user2],
          exclude_actions: %w[exclude1 exclude2],
          devices: %w[Bot Mobile Desktop Tablet Unknown],
          methods: %w[otp totp magiclink oauth saml password],
          geos: %w[US IL],
          remote_addresses: %w[remote1 remote2],
          login_ids: %w[login1 login2],
          tenants: %w[tenant1 tenant2],
          text: 'text123',
          from_ts: 1_234_567,
          to_ts: 123_456_789
        )
      end.not_to raise_error
      expect(res['audits'][0]['projectId']).to eq('abc')
    end
  end

  context '.create_event' do
    it 'should respond to .audit_create_event' do
      expect(@instance).to respond_to :audit_create_event
    end
    it 'should raise an error if type is not info, warn or error' do
      expect do
        @instance.audit_create_event(
          action: 'get',
          type: 'debug',
          data: { key: 'value' },
          user_id: 'user_id',
          actor_id: 'actor_id',
          tenant_id: 'tenant_id'
        )
      end.to raise_error(Descope::AuthException, 'type must be either info, warn or error')
    end

    it 'should raise an error if data is not a hash' do
      expect do
        @instance.audit_create_event(
          action: 'get',
          type: 'info',
          data: 'data',
          user_id: 'user_id',
          actor_id: 'actor_id',
          tenant_id: 'tenant_id'
        )
      end.to raise_error(Descope::AuthException, 'data must be provided (Hash)')
    end

    it 'should raise an error if data is an empty hash' do
      expect do
        @instance.audit_create_event(
          action: 'get',
          type: 'info',
          data: {},
          user_id: 'user_id',
          actor_id: 'actor_id',
          tenant_id: 'tenant_id'
        )
      end.to raise_error(Descope::AuthException, 'data must not be empty')
    end

    it 'should raise an error if tenant_id is not provided' do
      expect do
        @instance.audit_create_event(
          action: 'get',
          type: 'info',
          data: { key: 'value' },
          user_id: 'user_id',
          actor_id: 'actor_id'
        )
      end.to raise_error(Descope::AuthException, 'tenant_id must be provided')
    end

    it 'is expected to create an audit event' do
      expect(@instance).to receive(:post).with(
        '/v1/mgmt/audit/event',
        {
          action: 'get',
          type: 'info',
          actorId: 'actor_id',
          data: { key: 'value' },
          tenantId: 'tenant_id',
          userId: 'user_id'
        }
      )
      expect do
        @instance.audit_create_event(
          action: 'get',
          type: 'info',
          data: { key: 'value' },
          user_id: 'user_id',
          actor_id: 'actor_id',
          tenant_id: 'tenant_id'
        )
      end.not_to raise_error
    end
  end
end
