require_relative 'config'
require_relative 'infrastructure'
require_relative 'environment'

module Elevage
  # Platform class
  class Platform
    attr_accessor :name
    attr_accessor :description
    attr_accessor :environments
    attr_accessor :tiers
    attr_accessor :nodenameconvention
    attr_accessor :pools
    attr_accessor :components
    attr_accessor :vcenters
    attr_accessor :networks
    attr_accessor :compute

    def initialize(platform, infrastructure)
      @name =  platform.fetch('name')
      @description =  platform.fetch('description')
      @environments = platform.fetch('environments')
      @tiers = platform.fetch('tiers')
      @nodenameconvention = platform.fetch('nodenameconvention')
      @pools = platform.fetch('pool')
      @components = platform.fetch('components')
      @vcenters = infrastructure.fetch('vcenter')
      @networks = infrastructure.fetch('networks')
      @compute = infrastructure.fetch('compute')
    end

    def health

    end

    def to_s
      "\n#{@name}: #{description}"
    end
  end
end
