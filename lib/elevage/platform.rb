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

    def to_s
      puts "\n#{@platform.fetch('name')}: #{@platform.fetch('description')}\n\n"
    end

    # rubocop:disable all
    def list_items(item)
      case item
      when 'environments'
        puts @platform.fetch('environments')
      when 'tiers'
        puts @platform.fetch('tiers')
      when 'pools'
        puts @platform.fetch('pools').to_yaml
      when 'components'
        puts @platform.fetch('components').to_yaml
      when 'vcenter'
        puts @vcenter.fetch('locations').to_yaml
      when 'compute'
        puts @compute.fetch('options').to_yaml
      when 'networks'
        puts @network.to_yaml
      else
        if File.file?(ENVIRONMENTS_FOLDER + item + '.yml')
          environment = YAML.load_file(ENVIRONMENTS_FOLDER + item + '.yml').fetch('environment')
          environment['vcenter'] = @vcenter['locations'][environment['vcenter']]

          @platform['components'].each do |component, config|
            puts @platform['components'][component].to_yaml
            puts "\n\n"
            puts environment['components'][component].to_yaml
            environment['components'][component].merge!(@platform['components'][component]) { |key, v1, v2| v1 }
            puts environment['components'][component].to_yaml
            # config.each do |k,v|
            #   puts "platform:#{component}:#{k} = #{v}, #{item} = #{environment['components'][component]['tier']}"
            #   STDIN.gets
            #   environment['components'][component].merge!(@platform['components'][component]) { |key, v1, v2| v1 }
            #   puts ">>platform:#{component}:#{k} = #{v}, #{item} = #{environment['components'][component][k]}"
            #   # if environment['components'][component][k] != nil
            #   #   puts "nil"
            #   #   puts "env = #{environment['components'][component][k]}"
            #   #   puts "platform = #{@platform['components'][component][k]}"
            #   #   @platform['components'][component][k] = environment['components'][component][k]
            #   #   puts ">>platform:#{component}:#{k} = #{v}, #{item} = #{environment['components'][component][k]}"
            #   # end
            #   # environment['components'][component]=@platform['components'][component]
            #   # puts "platform:#{component}:#{k} = #{v}"
            # end
            STDIN.gets
          end

          # temphash = {'Db' => { 'network' => "proddb" }}
          # environment['environment']['tier'].merge! temphash

        else
          fail(IOError, ERROR_MSG[:unkown_list_command])
        end
      end
    end
    # rubocop:enable all

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
# def missing_environment_file?
#   environments = @platform.fetch('environments')
#   if environments.any?
#     environments.each do |env|
#       envfile = 'environments/' + env + '.yml'
#       missing_file_fail(envfile, ERROR_MSG[:missing_environment_file] + env)
#     end
#     false
#   else
#     fail(IOError, ERROR_MSG[:no_environments_defined])
#   end
# end
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
