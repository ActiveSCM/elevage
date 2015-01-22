require 'thor/group'

module Elevage
  # Create new platform definition files and environments folder structure
  class New < Thor::Group
    include Thor::Actions

    argument :platform

    def self.source_root
      File.dirname(__FILE__)
    end

    # Confirm command is not being run in folder with existing platform
    # definition
    def already_exists?
      File.file?(YML_PLATFORM) && fail(IOError, ERR[:platform_exists])
    end

    # Create the platform definition file
    def create_platform_file
      template(TEMPLATE_PLATFORM, YML_PLATFORM)
    end

    # Create the infrastructure definition files
    def create_infrastructure_files
      template(TEMPLATE_VCENTER, YML_VCENTER)
      template(TEMPLATE_NETWORK, YML_NETWORK)
      template(TEMPLATE_COMPUTE, YML_COMPUTE)
    end
  end
end
