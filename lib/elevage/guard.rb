require 'thor/group'
require_relative 'constants'
require_relative 'platform'

module Elevage
  # load Platform class object and perform health checks
  class Guard < Thor

    desc 'simple', DESC_GUARD_SIMPLE
    def simple
      platform = Elevage::Platform.new
      puts MSG_GUARD_SIMPLE_SUCCESS unless platform.missing_environment_file?
    end

    desc 'platform', DESC_GUARD_FULL
    def platform
      platform = Elevage::Platform.new
      unless platform.missing_environment_file?
        puts MSG_GUARD_PLATFORM_SUCCESS if platform.yml_files_consistent?
      end
    end
  end
end
