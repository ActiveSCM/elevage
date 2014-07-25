require 'YAML'
require 'thor/group'
require_relative 'constants'
require_relative 'platform'

module Elevage
  # Create new environment desired state files from platform template
  class List < Thor::Group
    include Thor::Actions

    argument :item

    def self.source_root
      File.dirname(__FILE__)
    end

    def list_platform_info
      @platform = Elevage::Platform.new.list_items(item)
    end
  end
end
