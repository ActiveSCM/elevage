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

    def create_environment
      fail IOError, ERROR_MSG[:environment_already_exists] if File.file?(ENV_FOLDER + env + '.yml')
      platform = Elevage::Platform.new
      puts platform
      # template(TEMPLATE_ENV, ENV_FOLDER + env + '.yml')
      puts "#{env}.yml added in environments folder"
    end
  end
end
