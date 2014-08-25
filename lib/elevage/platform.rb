require 'yaml'
require 'resolv'
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
      health += HEALTH_MSG[:empty_nodenameconvention] unless @environments.all?
      health += health_pools
      health += health_vcenter
      # Hash
      # puts @vcenter.class
      # puts @network.class
      # puts @compute.class
      if health.length > 0
        puts health
        puts "\n#{health.lines.count} offense(s) detected"
        false
      else
        true
      end
    end
    # rubocop:enable MethodLength

    private

    def health_vcenter
      health = ''
      @vcenter['locations'].each do |_pool,values|
        health += HEALTH_MSG[:invalid_geo] if values['geo'].nil?
        health += HEALTH_MSG[:invalid_timezone] unless (0..159).member?(values['timezone'].to_i)
        #health += HEALTH_MSG[:invalid_host] unless valid_vcenter_host?(values['host'])
        health += HEALTH_MSG[:invalid_datacenter] if values['datacenter'].nil?
        health += HEALTH_MSG[:invalid_imagefolder] if values['imagefolder'].nil?
        health += HEALTH_MSG[:invalid_destfolder] if values['destfolder'].nil?
        health += HEALTH_MSG[:invalid_appendenv] unless values['appendenv'] == true || values['appendenv'] == false
        health += HEALTH_MSG[:invalid_appenddomain] unless values['appenddomain'] == true || values['appenddomain'] == false
        health += HEALTH_MSG[:empty_datastores] unless values['datastores'].all?
        health += HEALTH_MSG[:invalid_domain] if values['domain'].nil?
        values['dnsips'].each { |ip| health += HEALTH_MSG[:invalid_ip] unless Resolv::IPv4::Regex.match(ip)}
      end
      health
    end

    # rubocop:disable all
    def health_pools
      health = ''
      @pools.each do |_pool, values|
        health += HEALTH_MSG[:pool_count_size] if values['count'].nil?
        health += HEALTH_MSG[:invalid_tiers] unless @tiers.include?(values['tier'])
        health += HEALTH_MSG[:no_image_ref] if values['image'].nil?
        health += HEALTH_MSG[:invalid_compute] unless @compute['options'].key?(values['compute'])
        health += HEALTH_MSG[:invalid_port] if values['port'].nil?
        health += HEALTH_MSG[:invalid_runlist] unless values['runlist'].all?
        health += HEALTH_MSG[:invalid_componentrole] unless values['componentrole'].include?('#') if values['componentrole']
      end
      health
    end
    # rubocop:enable all

    # Private: confirms existence of the standard platform defintion files
    #
    # Returns true/false, results of missing_file_fail call for standard files
    def platform_files_exists?
      missing_file_fail(YML_PLATFORM, ERROR_MSG[:no_platform_file]) &&
      missing_file_fail(YML_VCENTER, ERROR_MSG[:no_vcenter_file]) &&
      missing_file_fail(YML_NETWORK, ERROR_MSG[:no_network_file]) &&
      missing_file_fail(YML_COMPUTE, ERROR_MSG[:no_compute_file])
    end

    # Private: standard Ruby IOError fail based on existence of file
    # Params
    #   file: path/filename
    #   msg: string, message to write to console if fail
    #
    # Returns true (or fails)
    def missing_file_fail(file, msg)
      fail(IOError, msg) unless File.file?(file)
      true
    end

    def valid_vcenter_host?(address)
      # Net::HTTP.new(address).head('/').kind_of? Net::HTTPOK
      result = `ping -q -c 5 #{address}`
      $?.exitstatus == 0 ? true : false
    end
  end
end
