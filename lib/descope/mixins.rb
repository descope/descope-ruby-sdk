require 'rest-client'
require 'uri'

require 'descope/mixins/headers'
require 'descope/mixins/http'
require 'descope/mixins/initializer'
require 'descope/mixins/common'

require 'descope/api/v1'

module Descope
  # Collecting dependencies here
  module Mixins
    include Descope::Mixins::Common
    include Descope::Mixins::Headers
    include Descope::Mixins::HTTP
    include Descope::Mixins::Initializer
  end
end
