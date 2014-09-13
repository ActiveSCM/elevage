# rubocop:disable LineLength
require 'yaml'
require 'resolv'
require 'English'

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

    # rubocop:disable MethodLength
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
    # rubocop:enable MethodLength

    # rubocop:disable MethodLength
    def healthy?
      health = ''
      health += HEALTH_MSG[:empty_environments] unless @environments.all?
      health += HEALTH_MSG[:empty_tiers] unless @tiers.all?
      health += HEALTH_MSG[:empty_nodenameconvention] unless @nodenameconvention.all?
      health += health_pools + health_vcenter + health_network + health_compute
      if health.length > 0
        puts health + "\n#{health.lines.count} platform offense(s) detected"
        false
      else
        true
      end
    end
    # rubocop:enable MethodLength

    private

    def health_compute
      health = ''
      @compute.each do |_compute, v|
        health += HEALTH_MSG[:invalid_cpu_settings] unless (0..CPU_LIMIT).member?(v['cpu'])
        health += HEALTH_MSG[:invalid_ram_settings] unless (0..RAM_LIMIT).member?(v['ram'])
      end
      health
    end

    def health_network
      health = ''
      @network.each do |_network, v|
        health += HEALTH_MSG[:empty_network_definitions] if v.values.any? { |i| i.nil? }
        health += HEALTH_MSG[:invalid_gateway] unless Resolv::IPv4::Regex.match(v['gateway'])
      end
      health
    end

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity
    def health_vcenter
      health = ''
      @vcenter.each do |_vcenter, v|
        health += HEALTH_MSG[:invalid_geo] if v['geo'].nil?
        health += HEALTH_MSG[:invalid_timezone] unless (0..TIMEZONE_LIMIT).member?(v['timezone'].to_i)
        health += HEALTH_MSG[:invalid_host] unless valid_vcenter_host?(v['host'])
        health += HEALTH_MSG[:invalid_datacenter] if v['datacenter'].nil?
        health += HEALTH_MSG[:invalid_imagefolder] if v['imagefolder'].nil?
        health += HEALTH_MSG[:invalid_destfolder] if v['destfolder'].nil?
        health += HEALTH_MSG[:invalid_appendenv] unless v['appendenv'] == true || v['appendenv'] == false
        health += HEALTH_MSG[:invalid_appenddomain] unless v['appenddomain'] == true || v['appenddomain'] == false
        health += HEALTH_MSG[:empty_datastores] unless v['datastores'].all?
        health += HEALTH_MSG[:invalid_domain] if v['domain'].nil?
        v['dnsips'].each { |ip| health += HEALTH_MSG[:invalid_ip] unless Resolv::IPv4::Regex.match(ip) }
      end
      health
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity
    def health_pools
      health = ''
      @pools.each do |_pool, v|
        health += HEALTH_MSG[:pool_count_size] unless (0..POOL_LIMIT).member?(v['count'])
        health += HEALTH_MSG[:invalid_tiers] unless @tiers.include?(v['tier'])
        health += HEALTH_MSG[:no_image_ref] if v['image'].nil?
        health += HEALTH_MSG[:invalid_compute] unless @compute.key?(v['compute'])
        health += HEALTH_MSG[:invalid_port] if v['port'].nil?
        health += HEALTH_MSG[:invalid_runlist] unless v['runlist'].all?
        health += HEALTH_MSG[:invalid_componentrole] unless v['componentrole'].include?('#') if v['componentrole']
      end
      health
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity

    # Private: confirms existence of the standard platform defintion files
    # Returns true if all standard files present
    def platform_files_exists?
      fail(IOError, ERROR_MSG[:no_platform_file]) unless File.file?(YML_PLATFORM)
      fail(IOError, ERROR_MSG[:no_vcenter_file]) unless File.file?(YML_VCENTER)
      fail(IOError, ERROR_MSG[:no_network_file]) unless File.file?(YML_NETWORK)
      fail(IOError, ERROR_MSG[:no_compute_file]) unless File.file?(YML_COMPUTE)
      true
    end

    # Private: given a url or ip check for access
    #
    # Returns true/false based on simple ping check
    #   -would like to switch this to http or https based health check since
    #   actually need to confirm health for API access
    def valid_vcenter_host?(address)
      # Net::HTTP.new(address).head('/').kind_of? Net::HTTPOK
      # _result = `ping -q -c 3 #{address}`
      # $CHILD_STATUS.exitstatus == 0 ? true : false
      true
    end
  end
end
# rubocop:enable LineLength
