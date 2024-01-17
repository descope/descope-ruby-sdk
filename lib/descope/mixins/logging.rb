# frozen_string_literal: true

module Descope
  module Mixins
    # Module to provide logger.
    module Logging

      def logger
        # This is the magical bit that gets mixed into the other modules
        @logger ||= Logging.logger_for(self.class.name, 'info')
      end

      # Use a hash class-ivar to cache a unique Logger per class:
      @loggers = {}

      class << self
        def logger_for(classname, level)
          @loggers[classname] ||= configure_logger_for(classname, level)
        end

        def configure_logger_for(classname, level = 'info')
          logger = Logger.new(STDOUT                                                                             )
          logger.level = Object.const_get("Logger::#{level.upcase}")
          logger.progname = classname
          logger
        end
      end
    end
  end
end
