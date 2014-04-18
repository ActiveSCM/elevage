# gem dependencies
require 'thor'
require 'yaml'
# class definitions
require_relative 'elevage/config'
require_relative 'elevage/platform'
# subcommand parsers
require_relative 'elevage/new'
require_relative 'elevage/generate'

module Elevage
  # Initial Commandline instance of Thor class
  class CmdLine < Thor
    desc 'health', CMD_HEALTH
    method_option :verbose, type: :boolean, aliases: '-v'
    def health
      if File.file?(PLATFORM_YML)
        platformdata = YAML.load_file(PLATFORM_YML).fetch('platform')
        infrastructurefile = YAML.load_file(INFRA_YML)

        platform = Elevage::Platform.new(platformdata, infrastructurefile)
        puts platform if options.verbose?
        puts 'run health check'
      else
        say ERROR_MSG[:no_platform_file]
        exit(ERROR_NO[:no_platform_file])
      end
    end

    register(Elevage::New, 'new', 'new PLATFORM', CMD_NEW)
    register(Elevage::Generate, 'generate', 'generate COMPONENT', CMD_GENERATE)
  end
end
