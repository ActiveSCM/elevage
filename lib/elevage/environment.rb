require 'thor/group'

module Elevage

  class Environment < Thor::Group
    include Thor::Actions

    argument :environment#, :default => :template
    class_option :test_framework, :default => :rspec

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_environment_file
      puts "creating environment file"
    end

    def create_test_files
      test = options[:test_framework] == "testunit" ? :test : :spec
      puts "test type #{test}"
      #create_file "#{platform}/#{test}/#{platform}_#{test}.rb"
    end
  end

end
