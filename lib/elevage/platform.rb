require 'yaml'

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

    def to_s
      puts "\n#{@platform['name']}: #{@platform['description']}\n\n"
    end

    # rubocop:disable all
    def list_items(item, option)
      case item
      when 'environments'
        puts @platform.fetch('environments', MISSING_KEY)
      when 'tiers'
        puts @platform.fetch('tiers', MISSING_KEY)
      when 'pools'
        puts @platform.fetch('pools', MISSING_KEY).to_yaml
      when 'components'
        puts @platform.fetch('components', MISSING_KEY).to_yaml
      when 'vcenter'
        puts @vcenter.fetch('locations', MISSING_KEY).to_yaml
      when 'compute'
        puts @compute.fetch('options', MISSING_KEY).to_yaml
      when 'networks'
        puts @network.to_yaml
      else
        if File.file?(ENVIRONMENTS_FOLDER + item + '.yml')
          environment = build_environment_hash(YAML.load_file(ENVIRONMENTS_FOLDER + item + '.yml').fetch('environment'))
          if option
            environment['components'].each do |component, _config|
              (1..environment['components'][component]['count']).each do |i|
                puts environment['components'][component]['addresses'][i-1] + ' ' +node_name(environment['vcenter']['geo'].to_s,item,component,i)
              end
            end
          else
            puts environment.to_yaml
          end
        else
          fail(IOError, ERROR_MSG[:unkown_list_command])
        end
      end
    end
    # rubocop:enable all

    def healthy?
      puts @platform.include?('tier')

      # if @platform.value?('')
      #   puts 'fail' # all the right keys exist in standard files (and not nil)
      # end
      # values match
      # each env file contains the match platform components
      true
    end

    private

    # rubocop:disable all
    def node_name(geo, env, component, instance)
      name = ''
      @platform['nodenameconvention'].each do |i|
        case i
        when 'environment'
          name += env
        when 'component'
          name += component
        when 'instance'
          name += instance.to_s.rjust(2, '0')
        when 'geo'
          name += geo[0]
        else
          name += i
        end
      end
      name
    end
    # rubocop:enable all

    # rubocop:disable all
    def build_environment_hash(env_yaml)
      env_yaml['vcenter'] = @vcenter['locations'][env_yaml['vcenter']]
      # merge component resources from environment file and platform definition
      @platform['components'].each do |component, _config|
        env_yaml['components'][component].merge!(@platform['components'][component]) { |_key, v1, _v2| v1 }
      end
      # substitute network name with key values
      env_yaml['components'].each do |component, _config|
        env_yaml['components'][component]['network'] = @network[env_yaml['components'][component]['network']]
      end
      # substitute compute name with key values
      env_yaml['components'].each do |component, _config|
        env_yaml['components'][component]['compute'] = @compute['options'][env_yaml['components'][component]['compute']]
      end
      env_yaml
    end
    # rubocop:enable all

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
#
# def yml_files_consistent?
#   environments = @platform.fetch('environments')
#   if vm_resources_defined?
#     if Dir[ENVIRONMENTS_FOLDER + '*'].length == environments.size
#
#     else
#       fail(IOError, ERROR_MSG[:too_many_environment_files])
#     end
#   end
#   true
# end
#
# def vm_resources_defined?
#   name = @platform.fetch('name')
#   fail(IOError, ERROR_MSG[:compute_platform_name_mismatch]) if name != @compute.fetch('name')
#   check_keys_for_nil(@compute, 'options')
#   fail(IOError, ERROR_MSG[:vcenter_platform_name_mismatch]) if name != @vcenter.fetch('name')
#   check_keys_for_nil(@vcenter, 'locations')
#   true
# end
#
# def check_keys_for_nil(hash_to_check, option_key)
#   hash_to_check.fetch(option_key).each_value do |values|
#     values.each_value { |config| fail(IOError, ERROR_MSG[:nil_compute_values]) if config.nil? }
#   end
# end
