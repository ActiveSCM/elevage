require "awesome_print"
require_relative 'config'
require_relative 'infrastructure'
require_relative 'environment'

module Elevage
  # Platform class
  class Platform
    attr_accessor :name
    attr_accessor :environments
    attr_accessor :tiers
    attr_accessor :nodenameconvention

    def initialize
      # standard files that are part of every platform definition
      platformfile = YAML.load_file(PLATFORM_YML)
      infrastructurefile = YAML.load_file(INFRA_YML)

      # parse the standard files to populate class structure
      platformdata = platformfile.fetch('platform')

      @name =  platformdata.fetch('name')
      @environments = platformdata.fetch('environments')
      @tiers = platformdata.fetch('tiers')
      @nodenameconvention = platformdata.fetch('nodenameconvention')


      @vcenters = infrastructurefile.fetch('vcenter')
      @networks = infrastructurefile.fetch('networks')
      @compute = infrastructurefile.fetch('compute')
      @pools = platformdata.fetch('pool')
      @components = platformdata.fetch('components')
    end

    def health

    end

    def to_s
      puts "\n\t#{@name}:\n\n"
      puts "\tenvironments:\t#{@environments}"
      puts "\ttiers:\t\t#{@tiers}\n"
      @vcenters.each do |k, v|
        puts "\tvcenter: #{k}\n"
        vcenter = Elevage::Infrastructure.new(v)
        puts vcenter
      end
      @networks.each do |k, v|
        puts "\tnetworks: #{k}\n"
        network = Elevage::Network.new(v)
        puts network
      end
      # puts "\t#{@compute}"
      # puts "\t#{@pools}"
      # puts "\t#{@components}"


    end
  end
end
