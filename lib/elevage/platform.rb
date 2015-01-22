# rubocop:disable LineLength
require 'yaml'
require 'resolv'
require 'English'

module Elevage
  # Platform class
  #
  # This represents the overall description of the platform
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

    # rubocop:disable MethodLength

    # Create a new platform object
    # @return [Elevage::Platform]
    def initialize
      fail unless platform_files_exists?
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
    # rubocop:enable MethodLength

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity, AmbiguousOperator

    # Determine whether the platform definition is considered correct
    # return [Boolean]
    def healthy?
      health = ''
      # Array of string checked for empty values
      health += MSG[:empty_environments] unless @environments.all?
      health += MSG[:empty_tiers] unless @tiers.all?
      health += MSG[:empty_nodenameconvention] unless @nodenameconvention.all?
      # Loop through all pool definitions, check for valid settings
      @pools.each do |_pool, v|
        health += MSG[:pool_count_size] unless (0..POOL_LIMIT).member?(v['count'])
        health += MSG[:invalid_tiers] unless @tiers.include?(v['tier'])
        health += MSG[:no_image_ref] if v['image'].nil?
        health += MSG[:invalid_compute] unless @compute.key?(v['compute'])
        health += MSG[:invalid_port] if v['port'].nil?
        health += MSG[:invalid_runlist] unless v['runlist'].all?
        health += MSG[:invalid_componentrole] unless v['componentrole'].include?('#') if v['componentrole']
      end
      # Loop through all vcenter definitions, check for valid settings
      @vcenter.each do |_vcenter, v|
        health += MSG[:invalid_geo] if v['geo'].nil?
        health += MSG[:invalid_timezone] unless (0..TIMEZONE_LIMIT).member?(v['timezone'].to_i)
        health += MSG[:invalid_host] if v['host'].nil?
        health += MSG[:invalid_datacenter] if v['datacenter'].nil?
        health += MSG[:invalid_imagefolder] if v['imagefolder'].nil?
        health += MSG[:invalid_destfolder] if v['destfolder'].nil?
        health += MSG[:invalid_appendenv] unless v['appendenv'] == true || v['appendenv'] == false
        health += MSG[:invalid_appenddomain] unless v['appenddomain'] == true || v['appenddomain'] == false
        health += MSG[:empty_datastores] if v['datastore'].nil?
        health += MSG[:invalid_domain] if v['domain'].nil?
        v['dnsips'].each { |ip| health += MSG[:invalid_ip] unless Resolv::IPv4::Regex.match(ip) }
      end
      # Loop through all network definitions, check for valid settings
      @network.each do |_network, v|
        health += MSG[:empty_network] if v.values.any? &:nil?
        health += MSG[:invalid_gateway] unless Resolv::IPv4::Regex.match(v['gateway'])
      end
      # Loop through all compute definitions, check for valid settings
      @compute.each do |_compute, v|
        health += MSG[:invalid_cpu] unless (0..CPU_LIMIT).member?(v['cpu'])
        health += MSG[:invalid_ram] unless (0..RAM_LIMIT).member?(v['ram'])
      end
      if health.length > 0
        puts health + "\n#{health.lines.count} platform offense(s) detected"
        false
      else
        true
      end
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity, AmbiguousOperator

    private

    # Confirm existence of the standard platform definition files
    # @return [Boolean] True if all standard files present
    def platform_files_exists?
      fail(IOError, ERR[:no_platform_file]) unless File.file?(YML_PLATFORM)
      fail(IOError, ERR[:no_vcenter_file]) unless File.file?(YML_VCENTER)
      fail(IOError, ERR[:no_network_file]) unless File.file?(YML_NETWORK)
      fail(IOError, ERR[:no_compute_file]) unless File.file?(YML_COMPUTE)
      true
    end

    # Unimplemented - part of future Communication health check option
    # def valid_vcenter_host?(address)
    #   _result = `ping -q -c 3 #{address}`
    #   $CHILD_STATUS.exitstatus == 0 ? true : false
    #   true
    # end
  end
end
