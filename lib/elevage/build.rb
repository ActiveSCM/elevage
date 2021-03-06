require 'thor/group'

module Elevage
  # Create new platform definition files and environments folder structure,
  # used by the command line `build` option
  class Build < Thor::Group
    include Thor::Actions

    # Build subcommand arguments and options
    # rubocop:disable LineLength
    argument :env, type: :string, desc: DESC_BUILD
    class_option :all, type: :boolean, aliases: '-a', desc: DESC_BUILD_ALL
    class_option :tier, type: :string, aliases: '-t', desc: DESC_BUILD_TIER
    class_option :component, type: :string, aliases: '-c', desc: DESC_BUILD_COMPONENT
    class_option :node, type: :numeric, aliases: '-n', desc: DESC_BUILD_NODE
    class_option :concurrency, type: :numeric, aliases: '-C', default: 8, desc: DESC_BUILD_CONCURRENCY
    class_option :logfiles, type: :string, aliases: '-l', default: 'logs', desc: DESC_BUILD_LOGFILES
    class_option :verbose, type: :boolean, aliases: '-v', default: false
    # rubocop:enable LineLength

    # dry-run
    class_option 'dry-run', type: :boolean, desc: DESC_BUILD_DRY_RUN

    # Additional options for passing to the knife command
    # rubocop:disable LineLength
    class_option 'vsuser', default: 'svc_provisioner', type: :string, desc: DESC_BUILD_VSUSER
    class_option 'vspass', default: 'changeme', type: :string, desc: DESC_BUILD_VSPASS
    class_option 'ssh-user', default: 'knife', type: :string, aliases: '-x', desc: DESC_BUILD_SSH_USER
    class_option 'ssh-key', default: 'knife_rsa', type: :string, aliases: '-i', desc: DESC_BUILD_SSH_KEY
    class_option 'template-file', default: 'chef-full.erb', type: :string, aliases: '-t', desc: DESC_BUILD_TEMPLATE_FILE
    class_option 'bootstrap-version', default: '11.4.0', type: :string, aliases: '-b', desc: DESC_BUILD_BOOTSTRAP_VERSION
    # rubocop:enable LineLength

    def self.source_root
      File.dirname(__FILE__)
    end

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity

    # Process and execute the `build` command
    def build
      # Make the logfile directory if it doesn't exist
      Dir.mkdir(options[:logfiles]) unless Dir.exist?(options[:logfiles])

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

      if options[:node] && !options[:component]
        warn 'When requesting a --node you must specify which --component.'
        exit false
      end

      unless options[:all] || options[:tier] || options[:component]
        warn 'You must specify one of --all, --tier=<tier>, or --component=<component>'
        exit false
      end

      # Determine what, exactly, we're supposed to build
      if options[:all]
        # =============================================================
        # Build ALL THE THINGS!
        #
        @environment.provision(type: :all,
                               options: options)

      elsif options[:tier]
        # =============================================================
        # Build most of the things...
        #
        if options[:tier].eql?('tier')
          warn 'Was asked to build a tier, but was not told which one!'
          exit false
        end
        @environment.provision(type: :tier,
                               tier: options[:tier],
                               options: options)

      elsif options[:component]
        # =============================================================
        # Build a few things...
        #
        if options[:component].eql?('component')
          warn 'Was asked to build a component, but was not told which one!'
          exit false
        end
        # See if we're actually only supposed to build just one thing...
        if options[:node]
          @environment.provision(type: :node,
                                 component: options[:component],
                                 instance: options[:node],
                                 options: options)
        else
          @environment.provision(type: :component,
                                 component: options[:component],
                                 options: options)
        end
      end
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity
  end
end
