require 'thor/group'

module Elevage
  # Create new environment desired state files from platform template
  class Generate < Thor::Group
    include Thor::Actions
    argument :env

    def self.source_root
      File.dirname(__FILE__)
    end

    # rubocop:disable MethodLength, CyclomaticComplexity, PerceivedComplexity

    # Process the `generate` command to create a new environment file
    def create_environment
      fail IOError, ERR[:env_exists] if File.file?(ENV_FOLDER + env + '.yml')
      platform = Elevage::Platform.new
      platformfile = File.open(YML_PLATFORM, 'r')
      # TODO: The things from here forward I would rather have in the template
      # file but that is even uglier, trying to get formatting correct
      # will need to investigate some POWER erb skills to clean this up
      @env_pools = ''
      @env_components = ''
      line = ''
      line = platformfile.gets until line =~ /pools/
      platform.pools.each do |k, _v|
        line = platformfile.gets until line.include?(k)
        @env_pools += line
        next_line = platformfile.gets
        @env_pools += "#{next_line}" if next_line.include?('<<')
        @env_pools += "      network:\n\n"
      end
      line = platformfile.gets until line =~ /components/
      platform.components.each do |k, v|
        line = platformfile.gets until line.include?(k)
        @env_components += line
        next_line = platformfile.gets
        @env_components += "#{next_line}" if next_line.include?('<<')
        @env_components += "      addresses:\n"
        (1..v['count']).each { @env_components += "        -\n" }
        @env_components += "\n"
      end
      template(TEMPLATE_ENV, ENV_FOLDER + env + '.yml')
      puts "#{env}.yml added in environments folder"
    end
    # rubocop:enable MethodLength, CyclomaticComplexity, PerceivedComplexity
  end
end
