require 'thor/group'
require_relative 'constants'
require_relative 'platform'

module Elevage
  # Create new environment desired state files from platform template
  class Generate < Thor::Group
    include Thor::Actions

    argument :env

    def self.source_root
      File.dirname(__FILE__)
    end

    def already_exists?
      if File.file?('environments' + env + '.yml')
        fail IOError, ERROR_MSG[:environment_already_exists]
      end
    end

    def create_environment_file

    end
  end
end
