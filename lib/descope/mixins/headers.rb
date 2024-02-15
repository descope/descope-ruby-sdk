module Descope
  module Mixins
    module Headers
      # Descope default headers
      def client_headers
        {
          'Content-Type' => 'application/json',
          'x-descope-sdk-name': 'ruby',
          'x-descope-sdk-ruby-version': RUBY_VERSION,
          'x-descope-sdk-version': Descope::SDK_VERSION,
        }
      end
    end
  end
end
