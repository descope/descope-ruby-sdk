# frozen_string_literal: true

module Configuration
  module_function

  def config
    {
      base_uri: ENV.fetch('DESCOPE_BASE_URI', 'DESCOPE_BASE_URI'),
      project_id: ENV.fetch('DESCOPE_PROJECT_ID', 'DESCOPE_PROJECT_ID'),
      management_key: ENV.fetch('DESCOPE_MANAGEMENT_KEY', 'DESCOPE_MANAGEMENT_KEY')
    }
  end
end
