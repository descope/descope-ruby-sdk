# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Flow do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
  end

  it 'should return a list of flows' do
    flows = @client.list_or_search_flows['flows']
    expect(flows.length).to be > 5
  end

  it 'should search for the sign-up-or-in flow' do
    flows = @client.list_or_search_flows(['sign-up-or-in'])['flows']
    expect(flows.length).to eq(1)
    expect(flows[0]['name']).to eq('Sign Up or In')
  end

  it 'should export the sign-up-or-in flow' do
    export = @client.export_flow('sign-up-or-in')
    expect(export['flow']['name']).to eq('Sign Up or In')
    expect(export['screens'].length).to be > 1
  end

  it 'should import the sign-up-or-in flow' do
    flow = @client.export_flow('sign-up-or-in')
    imported_flow = @client.import_flow(flow_id: 'sign-up-or-in', flow: flow['flow'], screens: flow['screens'])
    expect(imported_flow).not_to be_nil
  end

  it 'should export the current project theme' do
    theme = @client.export_theme
    expect(theme['theme']['cssTemplate']).not_to be_empty
  end

  it 'should import the current project theme' do
    export_theme = @client.export_theme
    export_theme_current_version = export_theme['theme']['version']
    imported_theme = @client.import_theme(export_theme)
    expect(imported_theme['theme']['version']).to be(export_theme_current_version + 1)
  end
end
