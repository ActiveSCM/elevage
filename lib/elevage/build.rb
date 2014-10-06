require 'thor/group'

module Elevage
  # Create new platform definition files and environments folder structure
  class Build < Thor::Group
    include Thor::Actions

    argument :env, :type => :string, :desc => "The name of the environment to build things from."
    class_option :all, type: :boolean, aliases: '-a', desc: DESC_BUILD_ALL
    class_option :tier, type: :string, aliases: '-t', desc: DESC_BUILD_TIER
    class_option :component, type: :string, aliases: '-c', desc: DESC_BUILD_COMPONENT
    class_option :node, type: :numeric, aliases: '-n', desc: DESC_BUILD_NODE

    def self.source_root
      File.dirname(__FILE__)
    end

    def build_temp

      # Fetch the environment and make sure it passes basic health checks
      @environment = Elevage::Environment.new(env)
      fail(IOError) unless @environment.healthy?

      # =============================================================
      # Option sanity checking.
      #
      # What are we going to reject as invalid options?
      #
      if ((options[:all] && options[:tier]) \
           || (options[:all] && options[:component]) \
           || (options[:tier] && options[:component]))

        warn 'The --all, --tier and --component options may not be specified together.'
        exit false

      end

      if (options[:node] && ! options[:component])
        warn 'When requesting a --node you must specify which --component.'
        exit false
      end

      unless (options[:all] || options[:tier] || options[:component])
        warn 'You must specify one of --all, --tier=<tier>, or --component=<component>'
        exit false
      end

      # =============================================================
      # Build ALL THE THINGS!
      #
      if options[:all]
        puts 'Building ALL THE THINGS!'

        # @environment.provision(type: :all)

      end

      # =============================================================
      # Build most of the things...
      #
      if options[:tier]
        if options[:tier].eql?('tier')
          warn 'Was asked to build a tier, but was not told which one!'
          exit false
        end

        puts "Building the #{options[:tier]} tier."

        # @environment.provision(type: :tier, tier: options[:tier])

      end

      # =============================================================
      # Build a few things...
      #
      if options[:component]
        if (options[:component].eql?('component'))
          warn 'Was asked to build a component, but was not told which one!'
          exit false
        end

        # See if we're actually only supposed to build just one thing...
        if options[:node]
          puts "Building node #{options[:node]} of component #{options[:component]}"

          # @environment.provision(type: :node, component: options[:component], node: options[:node])

        else
          puts "Building all nodes for the #{options[:component]} component" if options[:component]

          # @environment.provision(type: :component, component: options[:component])

        end

      end

      # =============================================================

    end

  end
end
