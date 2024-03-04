# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Audit do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
  end


  it 'should search the audit trail for user operations' do
    res = @client.audit_search(actions: ['LoginSucceed'])
    expect(res).to be_a(Hash)
    expect(res['audits']).to be_a(Array)
  end
end
