require 'thor'
require 'yaml'
require_relative 'elevage/config'
require_relative 'elevage/new'
require_relative 'elevage/platform'
require_relative 'elevage/generate'

module Elevage
  # Initial Commandline instance of Thor class
  class CmdLine < Thor
    desc 'health', 'Health check on all PLATFORM definition files'
    method_option :document, :type => :boolean, :aliases => "-d"
    def health
      if File.file?(PLATFORM_YML)
        if options.document?
          platform = Elevage::Platform.new
          puts platform
        end
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
