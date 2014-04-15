require 'thor'
require 'yaml'

require_relative 'elevage/config'
require_relative 'elevage/new'
require_relative 'elevage/platform'
require_relative 'elevage/generate'


module Elevage

  class CmdLine < Thor

    desc 'health', 'Health check on all PLATFORM definition files'
    def health
      if File.file?(PLATFORM_YML)
        platform = Elevage::Platform.new(YAML.load_file(PLATFORM_YML).fetch('platform'))
        platform.health
      else
        say ERROR_MSG[:no_platform_file]
        exit(ERROR_NO[:no_platform_file])
      end
    end

    register(Elevage::New,'new', 'new PLATFORM', 'Prepare new platform description files and folder structure at current location')
    register(Elevage::Generate,'generate','generate COMPONENT','Generate specified platform COMPONENT definition files')
  end

end