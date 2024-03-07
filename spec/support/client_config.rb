# frozen_string_literal: true


module Configuration
  module_function

  def config
    raise 'DESCOPE_MANAGEMENT_KEY is not set' if ENV['DESCOPE_MANAGEMENT_KEY'].nil?
    raise 'DESCOPE_PROJECT_ID is not set' if ENV['DESCOPE_PROJECT_ID'].nil?

    {
      descope_base_uri: ENV.fetch('DESCOPE_BASE_URI', Descope::Mixins::Common::DEFAULT_BASE_URL),
      project_id: ENV.fetch('DESCOPE_PROJECT_ID', nil),
      management_key: ENV.fetch('DESCOPE_MANAGEMENT_KEY', nil),
      log_level: ENV.fetch('DESCOPE_LOG_LEVEL', 'info')
    }
  end
end
