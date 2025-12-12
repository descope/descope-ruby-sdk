# frozen_string_literal: true

require 'spec_helper'

describe Descope::Api::V1::Management::Project do
  before(:all) do
    raise 'DESCOPE_MANAGEMENT_KEY is not set' if ENV['DESCOPE_MANAGEMENT_KEY'].nil?

    @client = DescopeClient.new(Configuration.config)
    @export_output = @client.export_project
    @original_project_name = nil
  end

  context 'Test project methods' do
    before(:all) do
      # Get the current project name before we modify it
      # Store it so we can restore it later
      begin
        @original_project_name = @client.export_project['project']['name']
      rescue StandardError
        @original_project_name = 'Ruby-SDK-Prod'
      end
    end

    after(:all) do
      # Restore the original project name
      @client.rename_project(@original_project_name) if @original_project_name
    end

    it 'should rename a project' do
      # Use a unique name based on build prefix to avoid conflicts
      unique_name = "#{SpecUtils.build_prefix}TEST-Ruby-SDK-Prod"
      @client.rename_project(unique_name)
      
      # Verify the rename worked by checking export
      current_export = @client.export_project
      expect(current_export).to_not be_nil
      expect(current_export['project']).to_not be_nil
      expect(current_export['project']['name']).to eq(unique_name)
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
