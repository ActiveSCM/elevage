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
      if environments.any?
        environments.each do |env|
          envfile = 'environments/' + env + '.yml'
          missing_file_fail(envfile, ERROR_MSG[:missing_environment_file] + env)
        end
        false
      else
        fail(IOError, ERROR_MSG[:no_environments_defined])
      end
    end

    def yml_files_consistent?
      environments = @platform.fetch('environments')
      name = @platform.fetch('name')
      if vm_resources_defined?
        if Dir[ENVIRONMENTS_FOLDER + '*'].length == environments.size

        else
          fail(IOError, ERROR_MSG[:too_many_environment_files])
        end
      end
      true
    end

    def to_s
      puts "\n#{@platform.fetch('name')}: #{@platform.fetch('description')}\n\n"
    end

    private

    def vm_resources_defined?
      name = @platform.fetch('name')
      fail(IOError, ERROR_MSG[:compute_platform_name_mismatch]) if name != @compute.fetch('name')
      check_keys_for_nil(@compute, 'options')
      fail(IOError, ERROR_MSG[:vcenter_platform_name_mismatch]) if name != @vcenter.fetch('name')
      check_keys_for_nil(@vcenter, 'locations')
      true
    end

    def check_keys_for_nil(hash_to_check, option_key)
      hash_to_check.fetch(option_key).each_value do |values|
        values.each_value {|config| fail(IOError, ERROR_MSG[:nil_compute_values]) if config.nil?}
      end
    end

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
