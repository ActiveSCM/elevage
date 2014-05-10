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
  # First class object called at command line
  class CmdLine < Thor
    desc 'health', CMD_HEALTH
    method_option :verbose, type: :boolean, aliases: '-v'
    def health
      if File.file?(PLATFORM_YML)
        platformdata = YAML.load_file(PLATFORM_YML).fetch('platform')
        infrastructuredata = YAML.load_file(INFRA_YML).fetch('infrastructure')

        platform = Elevage::Platform.new(platformdata, infrastructuredata)
        puts platform if options.verbose?
        puts 'run health check'
      else
        fail IOError, ERROR_MSG[:no_platform_file]
      end
    end

    register(Elevage::New, 'news', 'news PLATFORM', CMD_NEW)
    register(Elevage::Generate, 'generate', 'generate COMPONENT', CMD_GENERATE)
  end
end
