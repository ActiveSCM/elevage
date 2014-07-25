require 'thor'
require 'elevage/version'
require 'elevage/constants'
require 'elevage/new'
require 'elevage/list'
require 'elevage/guard'

module Elevage
  # Start of application commandline parsing
  class CLI < Thor
    map '--version' => :version
    map '-v' => :version

    desc 'version', DESC_VERSION
    def version
      say VERSION
    end

    register(Elevage::New, 'new', 'new PLATFORM', DESC_NEW)
    register(Elevage::List, 'list', 'list ITEM', DESC_LIST)
    # register(Elevage::Guard, 'guard', 'guard CHECK', DESC_GUARD)
    # register(Elevage::Generate, 'generate', 'generate ENV', DESC_GENERATE)
  end
end
