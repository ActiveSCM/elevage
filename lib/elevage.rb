require 'thor'
require_relative 'elevage/version'

module Elevage
  # Start of application commandline parsing
  class CLI < Thor
    map '--version' => :version
    map '-v' => :version

    desc 'version', 'Display installed elevage gem version (Can also use -v)'
    def version
      say VERSION
    end

  end
end