require 'thor'
require 'elevage/version'
require 'elevage/constants'
require 'elevage/new'
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
    register(Elevage::Guard, 'guard', 'guard', DESC_GUARD)
  end
end
