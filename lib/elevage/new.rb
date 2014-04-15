require 'thor/group'
require_relative 'config'

module Elevage

  class New < Thor::Group
  include Thor::Actions

    argument :platform
    class_option :development_environment, :default => Elevage::DEV_ENVIRONMENT

    def self.source_root
      File.dirname(__FILE__)
    end

    #def debug1
    #  invoke :generate
    #  exit(2)
    #end

    def already_exists?
      if File.directory?("#{platform}")
        say ERROR_MSG[:platform_already_exists]
        exit(ERROR_NO[:platform_already_exists])
      end
    end

    def create_infrastructure_file
      template('templates/infrastructure.yml.tt',"#{platform}/infrastructure.yml")
    end

    def create_platform_file
      template('templates/platform.yml.tt',"#{platform}/platform.yml")
    end

    def create_environment_files
      template('templates/environment.yml.tt',"#{platform}/#{Elevage::ENVIRONMENTS_DIR}/#{options[:development_environment]}.yml")
    end

  end

end