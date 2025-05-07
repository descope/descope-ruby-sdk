# frozen_string_literal: true

module Descope
  module Mixins
    # Module to provide logger.
    module Logging

      def logger
        # This is the magical bit that gets mixed into the other modules
        @logger ||= Logging.logger_for(self.class.name, 'info', @project_id)
      end

      # Use a hash class-ivar to cache a unique Logger per class:
      @loggers = {}

      class << self
        def logger_for(classname, level, project_id = nil)
          key = "#{classname}-#{project_id}"
          @loggers[key] ||= configure_logger_for(classname, level, project_id)
        end

        def configure_logger_for(classname, level = 'info', project_id = nil)
          logger = Logger.new(STDOUT)
          logger.level = Object.const_get("Logger::#{level.upcase}")
          logger.progname = classname

          # Adding Custom Formatter for Project ID
          logger.formatter = proc do |severity, datetime, progname, msg|
            project_info = project_id ? "PRID: #{project_id}" : ""
            "[#{datetime}] #{severity} #{project_info} #{progname}: #{msg}\n"
          end

          logger
        end
      end
    end
  end
end
