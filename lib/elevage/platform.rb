module Elevage
  class Platform
    attr_accessor :name

    def initialize(platform)
      @name = platform
      template('platform.yml.tt', 'platform.yml')
    end

    def to_s
      "\n#{@name}"
    end
  end
end