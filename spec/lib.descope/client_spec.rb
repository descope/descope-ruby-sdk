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
  end

  let(:project_id) { 'P2AbcZVJYEUBGhX8LNjItawh5nAp' }
  let(:management_key) { 'Abcdefg' }

  describe 'V1 client with token' do
    let(:subject) do
      Descope::Client.new(
        project_id: project_id,
        management_key: management_key
      )
    end
    it_should_behave_like 'v1 API client'
  end
end
