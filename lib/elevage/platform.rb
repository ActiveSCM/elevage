module Elevage

  class Platform
    attr_accessor :name
    attr_accessor :environments
    attr_accessor :tiers
    attr_accessor :nodenameconvention

    def initialize(yml)
      @name =  yml.fetch("name")
      @environments = yml.fetch("environments")
      @tiers = yml.fetch("tiers")
      @nodenameconvention = yml.fetch("nodenameconvention")
    end

    def health
      puts "\t\n#{@name}:\n\n"
      puts "\t#{@environments.size} environments defined"
      puts "\t#{@tiers.size} tiers defined"
    end

  end
end