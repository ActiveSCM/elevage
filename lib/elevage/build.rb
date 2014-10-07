require 'thor/group'

module Elevage
  # Create new platform definition files and environments folder structure
  class Build < Thor::Group
    include Thor::Actions

    # Build subcommand arguments and options
    argument :env, type: :string, desc: DESC_BUILD
    class_option :all, type: :boolean, aliases: '-a', desc: DESC_BUILD_ALL
    class_option :tier, type: :string, aliases: '-t', desc: DESC_BUILD_TIER
    class_option :component, type: :string, aliases: '-c', desc: DESC_BUILD_COMPONENT
    class_option :node, type: :numeric, aliases: '-n', desc: DESC_BUILD_NODE

    # dry-run
    class_option 'dry-run', type: :boolean, desc: DESC_BUILD_DRY_RUN

    # Additional options for passing to the knife command
    class_option 'vsuser', required: true, type: :string, desc: DESC_BUILD_VSUSER
    class_option 'vspass', required: true, type: :string, desc: DESC_BUILD_VSPASS
    class_option 'ssh-user', required: true, type: :string, aliases: '-x', desc: DESC_BUILD_SSHUSER
    class_option 'ssh-key', required: true, type: :string, aliases: '-i', desc: DESC_BUILD_SSHKEY
    class_option 'template-file', required: true, type: :string, aliases: '-t', desc: DESC_BUILD_TEMPLATE_FILE
    class_option 'bootstrap-file', required: true, type: :string, aliases: '-b', desc: DESC_BUILD_BOOTSTRAP_VERSION

    def self.source_root
      File.dirname(__FILE__)
    end

    def build

      # Fetch the environment and make sure it passes basic health checks
      @environment = Elevage::Environment.new(env)
      fail(IOError) unless @environment.healthy?

      # =============================================================
      # Option sanity checking.
      #
      # What are we going to reject as invalid options?
      #
      if options[:all] && options[:tier] || options[:all] && options[:component] || options[:tier] && options[:component]
        warn 'The --all, --tier and --component options may not be specified together.'
        exit false
      end

      if options[:node] && ! options[:component]
        warn 'When requesting a --node you must specify which --component.'
        exit false
      end

      unless options[:all] || options[:tier] || options[:component]
        warn 'You must specify one of --all, --tier=<tier>, or --component=<component>'
        exit false
      end

      # =============================================================
      # Build ALL THE THINGS!
      #
      if options[:all]
        @environment.provision(type: :all, options: options)
      end

      # =============================================================
      # Build most of the things...
      #
      if options[:tier]
        if options[:tier].eql?('tier')
          warn 'Was asked to build a tier, but was not told which one!'
          exit false
        end
        @environment.provision(type: :tier, tier: options[:tier], options: options)
      end

      # =============================================================
      # Build a few things...
      #
      if options[:component]
        if options[:component].eql?('component')
          warn 'Was asked to build a component, but was not told which one!'
          exit false
        end
        # See if we're actually only supposed to build just one thing...
        if options[:node]
          @environment.provision(type: :node, component: options[:component], instance: options[:node], options: options)
        else
          @environment.provision(type: :component, component: options[:component], options: options)
        end
      end

    end

  end
end
