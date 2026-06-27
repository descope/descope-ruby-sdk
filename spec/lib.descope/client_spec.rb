require 'spec_helper'

describe Descope::Client do
  shared_examples_for 'v1 API client' do
    it { should be_a Descope::Api::V1 }
    it { should be_a Descope::Api::V1::Management }
    it { should be_a Descope::Api::V1::Management::User }
    it { should be_a Descope::Api::V1::Management::Flow }
    it { should be_a Descope::Api::V1::Management::AccessKey }
    it { should be_a Descope::Api::V1::Management::Tenant }
    it { should be_a Descope::Api::V1::Management::Permission }
    it { should be_a Descope::Api::V1::Management::Role }
    it { should be_a Descope::Api::V1::Management::Project }
    it { should be_a Descope::Api::V1::Management::Authz }
    it { should be_a Descope::Api::V1::Management::Audit }
    it { should be_a Descope::Api::V1::Session }
    it { should be_a Descope::Api::V1::Auth }
    it { should be_a Descope::Api::V1::Auth::Password }
    it { should be_a Descope::Api::V1::Auth::EnchantedLink }
    it { should be_a Descope::Api::V1::Auth::MagicLink }
    it { should be_a Descope::Api::V1::Auth::OAuth }
    it { should be_a Descope::Api::V1::Auth::OTP }
    it { should be_a Descope::Api::V1::Auth::SAML }
    it { should be_a Descope::Api::V1::Auth::SAML }
    it { should be_a Descope::Api::V1::Auth::TOTP }
  end

  let(:project_id) { 'P2AbcZVJYEUBGhX8LNjItawh5nAp' }
  let(:management_key) { 'Abcdefg' }

  describe 'V1 client with token' do
    let(:subject) do
      Descope::Client.new(
        project_id:,
        management_key:
      )
    end
    it_should_behave_like 'v1 API client'
  end

  describe 'timeout configuration' do
    it 'uses the timeout_seconds option as the HTTP timeout' do
      client = Descope::Client.new(project_id:, management_key:, timeout_seconds: 17)
      expect(client.timeout).to eq(17)
    end

    it 'defaults to DEFAULT_TIMEOUT_SECONDS when timeout_seconds is not provided' do
      client = Descope::Client.new(project_id:, management_key:)
      expect(client.timeout).to eq(Descope::Mixins::Common::DEFAULT_TIMEOUT_SECONDS)
    end
  end
end
