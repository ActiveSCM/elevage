require 'thor'
require 'elevage/version'
require 'elevage/constants'
require 'elevage/new'
require 'elevage/platform'
require 'elevage/environment'
require 'elevage/health'
require 'elevage/generate'

# Refer to README.md for use instructions
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
    # rubocop:disable LineLength
    def list(item)
      # errors handled in class methods
      if LIST_CMDS.include?(item)
        puts Elevage::Platform.new.send(item).to_yaml
      else
        fail(IOError, ERR[:not_list_cmd]) unless File.file?(ENV_FOLDER + item + '.yml')
        environment = Elevage::Environment.new(item)
        puts options[:nodes] ? environment.list_nodes : environment
      end
    end
    # rubocop:enable LineLength

    # subcommand in Thor called as registered class
    register(Elevage::New, 'new', 'new PLATFORM', DESC_NEW)
    register(Elevage::Health, 'health', 'health', DESC_HEALTH)
    register(Elevage::Generate, 'generate', 'generate ENV', DESC_GENERATE)
  end
end
