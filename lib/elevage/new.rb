require 'thor/group'
require_relative 'config'

module Elevage
  # Create new provision file structure
  class New < Thor::Group
    include Thor::Actions

    argument :platform
    class_option :dev_env, default: Elevage::DEV_ENV

    def self.source_root
      File.dirname(__FILE__)
    end

    def already_exists?
      if File.directory?("#{platform}")
        raise ERROR_MSG[:platform_already_exists]
        #exit(ERROR_NO[:platform_already_exists])
      end
    end

    def create_infrastructure_file
      infra_loc = "#{platform}/infrastructure.yml"
      template(TEMPLATE_INFRA, infra_loc)
    end

    def create_platform_file
      platform_loc = "#{platform}/platform.yml"
      template(TEMPLATE_PLATFORM, platform_loc)
    end

    def create_environment_files
      env_loc = "#{platform}/#{Elevage::ENV_DIR}/#{options[:dev_env]}.yml"
      template(TEMPLATE_ENV, env_loc)
    end
  end
end
