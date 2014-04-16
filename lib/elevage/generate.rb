require 'thor'
require_relative 'config'
require_relative('env')

module Elevage
  # Generate subcommand Thor class
  class Generate < Thor
    include Thor::Actions

    desc 'status ENV', 'Inspect validity of environment definition'
    def status(env)
      puts "You requested a health status check of the #{env} definition"
    end

    register(Elevage::Env, 'env', 'env ENVIRONMENT', CMD_ENV)
  end
end
