require 'thor'
require 'elevage/version'
require 'elevage/constants'
require 'elevage/new'
require 'elevage/platform'

# Elevage is a command line tool that can manage the automated provisioning of virtual servers
# Refer to README.md for use instructions
#
# all classes wrapped in Elevage module to support release as Gem
#
module Elevage
  # Start of main CLI
  class CLI < Thor
    package_name 'elevage'
    map '--version' => :version
    map '-v' => :version

    desc 'version', DESC_VERSION
    def version
      puts VERSION
    end

    desc 'list ITEM', DESC_LIST
    method_option :nodes, aliases: '-n', desc: DESC_LIST_NODES
    def list(item)
      # errors handled in class methods
      @platform = Elevage::Platform.new
      if LIST_CMDS.include?(item)
        puts @platform.send(item).to_yaml
      else
        fail(IOError, ERROR_MSG[:unknown_list_cmd]) unless File.file?(ENV_FOLDER + item + '.yml')
        environment = Elevage::Environment.new(item, @platform)
        puts options[:nodes] ? environment.list_nodes : environment
      end
    end

    desc 'health', DESC_HEALTH
    method_option :environments, aliases: '-e', desc: DESC_HEALTH_ENV
    def health
      # errors handled in class methods
      platform = Elevage::Platform.new
      if options[:environments]
        platform.environments.each do |env|
          if Elevage::Environment.new(env, platform).healthy?
            puts env + MSG_ENV_HEALTH_SUCCESS
          else
            fail(IOError, ERROR_MSG[:fail_health_check])
          end
          #check for extra files
        end
      else
        if platform.healthy?
          puts MSG_HEALTH_SUCCESS
        else
          fail(IOError, ERROR_MSG[:fail_health_check])
        end
      end
    end

    # subcommand in Thor called as registered classes
    register(Elevage::New, 'new', 'new PLATFORM', DESC_NEW)
    # register(Elevage::Generate, 'generate', 'generate ENV', DESC_GENERATE)
  end
end
