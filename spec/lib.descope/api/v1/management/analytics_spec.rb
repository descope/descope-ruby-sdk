# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Analytics do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Api::V1::Management::Analytics)
    @instance = dummy_instance
  end

  context '.search' do
    let(:mock_response) do
      {
        'analytics' => [
          {
            'projectId' => 'abc',
            'action' => 'get',
            'created' => '1234567000',
            'device' => 'mobile',
            'method' => 'post',
            'geo' => 'US',
            'tenant' => 'tenant1',
            'referrer' => 'referrer1',
            'cnt' => '5'
          }
        ]
      }
    end

    before do
      allow(@instance).to receive(:post).with(
        ANALYTICS_SEARCH_PATH,
        {
          from: 1_234_567_000,
          to: 123_456_789_000,
          groupByAction: true,
          groupByDevice: true,
          groupByMethod: true,
          groupByGeo: true,
          groupByTenant: true,
          groupByReferrer: true,
          groupByCreated: true,
          actions: %w[action1 action2],
          excludedActions: %w[exclude1 exclude2],
          devices: %w[Bot Mobile Desktop Tablet Unknown],
          methods: %w[otp totp magiclink oauth saml password],
          geos: %w[US IL],
          tenants: %w[tenant1 tenant2]
        }
      ).and_return(mock_response)
    end

    it 'should respond to .analytics_search' do
      expect(@instance).to respond_to :analytics_search
    end

    it 'is expected to search analytics and get records' do
      res = nil # define res outside the block
      expect do
        res = @instance.analytics_search(
          from_ts: 1_234_567_000,
          to_ts: 123_456_789_000,
          group_by_action: true,
          group_by_device: true,
          group_by_method: true,
          group_by_geo: true,
          group_by_tenant: true,
          group_by_referrer: true,
          group_by_created: true,
          actions: %w[action1 action2],
          excluded_actions: %w[exclude1 exclude2],
          devices: %w[Bot Mobile Desktop Tablet Unknown],
          methods: %w[otp totp magiclink oauth saml password],
          geos: %w[US IL],
          tenants: %w[tenant1 tenant2]
        )
      end.not_to raise_error
      expect(res['analytics'][0]['projectId']).to eq('abc')
    end
  end
end
