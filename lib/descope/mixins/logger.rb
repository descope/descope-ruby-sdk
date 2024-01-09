# frozen_string_literal: true

module Descope
  module Mixins
    # Module to provide logger.
    module Logger
      def logger
        @logger ||= Descope::Mixins::Logger.logger_for(self.class.name, options[:log_level] || 'info')
      end

      # Use a hash class-ivar to cache a unique Logger per class:
      @loggers = {}
      class << self
        def logger_for(class_name, level)
          @loggers[class_name] ||= configure_logger_for(level)
        end

        def configure_logger_for(level)
          logger = Logger.new(STDOUT)
          logger.level = Object.const_get("Logger::#{level.upcase}")
          logger
        end
      end
    end
  end
end