require 'yaml'
require_relative 'environment'

module Elevage
  # Platform class
  class Platform
    attr_accessor :name, :description
    attr_accessor :environments
    attr_accessor :tiers
    attr_accessor :nodenameconvention
    attr_accessor :pools
    attr_accessor :components
    attr_accessor :vcenter
    attr_accessor :network
    attr_accessor :compute

    # rubocop:disable all
    def initialize
      if platform_files_exists?
        platform = YAML.load_file(YML_PLATFORM).fetch('platform')
        @name = platform['name']
        @description = platform['description']
        @environments = platform['environments']
        @tiers = platform['tiers']
        @nodenameconvention = platform['nodenameconvention']
        @pools = platform['pools']
        @components = platform['components']
        @vcenter = YAML.load_file(YML_VCENTER).fetch('vcenter')
        @network = YAML.load_file(YML_NETWORK).fetch('network')
        @compute = YAML.load_file(YML_COMPUTE).fetch('compute')
      end
    end
    # rubocop:enable all

    def healthy?
      # if @platform.value?('')
      #   puts 'fail' # all the right keys exist in standard files (and not nil)
      # end
      # values match
      # each env file contains the match platform components
      true
    end

    private

    def platform_files_exists?
      missing_file_fail(YML_PLATFORM, ERROR_MSG[:no_platform_file]) &&
      missing_file_fail(YML_VCENTER, ERROR_MSG[:no_vcenter_file]) &&
      missing_file_fail(YML_NETWORK, ERROR_MSG[:no_network_file]) &&
      missing_file_fail(YML_COMPUTE, ERROR_MSG[:no_compute_file])
    end

    def missing_file_fail(file, msg)
      fail(IOError, msg) unless File.file?(file)
      true
    end
  end
end
