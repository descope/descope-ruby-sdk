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
end
