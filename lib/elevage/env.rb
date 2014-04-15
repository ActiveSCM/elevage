require 'thor/group'

module Elevage

  class Env < Thor::Group
    include Thor::Actions

    argument :environment

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_environment_file
      puts "creating environment file"
    end

  end
end
