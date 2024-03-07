# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Project do
  before(:all) do
    @client = DescopeClient.new(Configuration.config)
    @export_output = @client.export_project
  end

  context 'Test project methods' do
    after(:all) do
      @client.rename_project('Ruby-SDK-Prod')
    end

    it 'should rename a project' do
      @client.rename_project('TEST-Ruby-SDK-Prod')
    end

    it 'should export a project' do
      expect(@export_output).to_not be_empty
      expect(@export_output).to be_a(Hash)
    end

    it 'should import a project' do
      @client.import_project(files: @export_output['files'])
    end
  end
end
