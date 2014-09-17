require 'thor/group'

module Elevage
  # Evaluate health of platform definition files
  class Health < Thor::Group
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    # rubocop:disable LineLength
    def check_platform
      @platform = Elevage::Platform.new
      puts @platform.healthy? ? MSG_HEALTHY : fail(IOError, ERR[:fail_health_check])
    end
    # rubocop:enable LineLength

    # rubocop:disable LineLength
    def check_environments
      @platform.environments.each do |env|
        puts Elevage::Environment.new(env).healthy? ? (env + MSG_ENV_HEALTHY) : fail(IOError, ERR[:fail_health_check])
      end
    end
    # rubocop:enable LineLength
  end
end
