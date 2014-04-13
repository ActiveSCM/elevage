require 'thor'
require_relative('environment')

module Elevage

  class Generate < Thor
    include Thor::Actions

    desc 'status ENV', "Inspect validity of environment definition"
    def status(env)
      puts "You requested a health status check of the #{env} definition"
    end

    register(Elevage::Environment,"environment","environment ENVIRONMENT","Prepare new environment description file")
  end

end