require 'thor'
require 'elevage/version'
require 'elevage/constants'
require 'elevage/new'
require 'elevage/platform'

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
    method_option :nodes, aliases: '-n', desc: DESC_LSIT_NODES
    def list(item)
      # error messages handled in class methods
      @platform = Elevage::Platform.new
      if LIST_CMDS.include?(item)
        puts @platform.send(item).to_yaml
      else
        fail(IOError, ERROR_MSG[:unkown_list_command]) unless File.file?(ENVIRONMENTS_FOLDER + item + '.yml')
        environment = Elevage::Environment.new(item, @platform)
        if options[:nodes]
          environment.list_nodes
        else
          puts environment
        end
      end
    end

    desc 'health', DESC_HEALTH
    def health
      # error messages handled in class methods
      puts MSG_HEALTH_SUCCESS if (@platform = Elevage::Platform.new.healthy?)
    end

    register(Elevage::New, 'new', 'new PLATFORM', DESC_NEW)
    # register(Elevage::Generate, 'generate', 'generate ENV', DESC_GENERATE)
  end
end
