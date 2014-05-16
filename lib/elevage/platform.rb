require 'YAML'

module Elevage
  # Platform class
  class Platform
    attr_accessor :platform
    attr_accessor :vcenter
    attr_accessor :network
    attr_accessor :compute

    def initialize
      if platform_files_exists?
        @platform = YAML.load_file(YML_PLATFORM).fetch('platform')
        @vcenter = YAML.load_file(YML_VCENTER).fetch('vcenter')
        @network = YAML.load_file(YML_NETWORK).fetch('network')
        @compute = YAML.load_file(YML_COMPUTE).fetch('compute')
      end
    end

    def missing_environment_file?
      environments = @platform.fetch('environments')
      environments.each do |env|
        envfile = 'environments/' + env + '.yml'
        missing_file_fail(envfile, ERROR_MSG[:missing_environment_file] + env)
      end
      false
    end

    def to_s
      "\n#{@platform.fetch('name')}: #{@platform.fetch('description')}\n\n"
    end

    private

    def platform_files_exists?
      missing_file_fail(YML_PLATFORM, ERROR_MSG[:no_platform_file]) &&
      missing_file_fail(YML_VCENTER, ERROR_MSG[:no_vcenter_file]) &&
      missing_file_fail(YML_NETWORK, ERROR_MSG[:no_network_file]) &&
      missing_file_fail(YML_COMPUTE, ERROR_MSG[:no_compute_file])
    end

    def missing_file_fail(file, msg)
      File.file?(file) ? true : fail(IOError, msg)
    end
  end
end

#
# @description = platformdata.fetch('description')
# @environments = platformdata.fetch('environments')
# @tiers = platformdata.fetch('tiers')
# @nodenameconvention = platformdata.fetch('nodenameconvention')
# @pools = platform.fetch('pool')
# @components = platform.fetch('components')
