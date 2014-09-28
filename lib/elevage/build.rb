require 'thor/group'

module Elevage
  # Create new platform definition files and environments folder structure
  class Build < Thor::Group
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def build_temp
      puts 'build'
    end
  end
end
