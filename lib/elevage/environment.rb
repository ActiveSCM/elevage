# Environmont level classes
module Elevage
  # vm components
  class Pool
    attr_accessor :pools

    def initialize(yml)
      @pools = yml
      @pools.each do |k, v|
        puts "#{k} contains #{v}"
      end
    end
  end

  class Component
    def initialize(yml)
      @components = yml
      @components.each do |k, v|
        puts "#{k} contains #{v}"
      end
    end
  end

  class Environment
    # class def here
  end
end
