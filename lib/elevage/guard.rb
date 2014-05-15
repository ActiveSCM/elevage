require 'thor/group'
require_relative 'constants'

module Elevage
  # load Platform clas object and perform health check
  class Guard < Thor::Group
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def platform_exists?
      unless File.file?(YML_PLATFORM)
        fail IOError, ERROR_MSG[:no_platform_file]
      end
    end

    # def load_platform_files
    #
    # end

    def inspect_defintion_health
      puts 'Guard status:'
    end
  end
end
