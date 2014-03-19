class Elevage < Thor
	include Thor::Actions

	desc "new PLATFORM", "build new platform folder structure"
	method_option :force, :type => :boolean, :default => false, :aliases => "-f", :required => false

	def new(platform)
 		puts "You supplied the platform name #{platform}"
	end

	desc "environment ENV", "create environment definition file"
	method_option :force, :type => :boolean, :default => false, :aliases => "-f", :required => false

	def environment(env)
		puts "you supplied the environment name #{env}"
	end

	def self.source_root
	end
end