# frozen_string_literal: true

module Configuration
  module_function

  def config
    {
      base_uri: ENV.fetch('DESCOPE_BASE_URI', nil),
      project_id: ENV.fetch('DESCOPE_PROJECT_ID', nil),
      management_key: ENV.fetch('DESCOPE_MANAGEMENT_KEY', nil),
      log_level: ENV.fetch('DESCOPE_LOG_LEVEL', 'info')
    }
  end
end
