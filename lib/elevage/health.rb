require 'thor/group'
require_relative 'constants'
require_relative 'platform'

module Elevage
  # load Platform class object and perform health checks
  class Health < Thor
    desc 'platform', DESC_HEALTH_PLATFORM
    def platform
      platform = Elevage::Platform.new
      unless platform.missing_environment_file?

      end
    end
  end
end
