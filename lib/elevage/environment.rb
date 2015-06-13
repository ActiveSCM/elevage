require 'yaml'
require 'resolv'

require_relative 'constants'
require_relative 'platform'
require_relative 'provisioner'

# Refer to README.md for use instructions
module Elevage
  # rubocop:disable ClassLength

  # Environment class
  class Environment
    attr_accessor :name
    attr_accessor :vcenter
    attr_accessor :components
    attr_accessor :nodenameconvention

    # rubocop:disable LineLength

    # Construct a new environment object.
    # @param [String] env Name of the environment to construct
    # @return [Elevage::Environment]
    def initialize(env)
      # Confirm environment has been defined in the platform
      platform = Elevage::Platform.new
      fail(IOError, ERR[:env_not_defined]) unless platform.environments.include?(env)
      # Confirm environment file exists
      envfile = ENV_FOLDER + env.to_s + '.yml'
      fail(IOError, ERR[:no_env_file]) unless env_file_exists?(envfile)
      # Build environment hash from environment and platform defintion files
      environment = build_env(env, YAML.load_file(envfile).fetch('environment'), platform)
      # Populate class variables
      @name = env
      @vcenter = environment['vcenter']
      @components = environment['components']
      @nodenameconvention = platform.nodenameconvention
    end
    # rubocop:enable LineLength

    # List the nodes for this environment.
    # Returns multiline string = IP, fqdn, runlist
    # @return [String] Expanded node list
    def list_nodes
      nodes =  @vcenter['destfolder'].to_s + "\n"
      @components.each do |component, _config|
        (1..@components[component]['count']).each do |i|
          nodes += @components[component]['addresses'][i - 1].ljust(18, ' ') +
                   node_name(component, i) + @vcenter['domain'] + '   ' +
                   @components[component]['runlist'].to_s + "\n"
        end
      end
      nodes
    end

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity

    # Is the environment healthy?
    # @return [Boolean] Health status of the environment
    def healthy?
      platform = Elevage::Platform.new
      health = ''
      health += MSG[:invalid_env_vcenter] if @vcenter.nil?
      @components.each do |component, v|
        health += MSG[:invalid_env_network] if v['network'].nil?
        health += MSG[:invalid_env_count] unless (0..POOL_LIMIT).member?(v['count'])
        health += MSG[:invalid_env_compute] if v['compute'].nil?
        health += MSG[:invalid_env_ip] if v['count'] != v['addresses'].size
        if v['addresses'].nil?
          health += MSG[:invalid_env_ip]
        else
          v['addresses'].each { |ip| health += MSG[:invalid_env_ip] unless Resolv::IPv4::Regex.match(ip) }
        end
        health += MSG[:invalid_env_tier] unless platform.tiers.include?(v['tier'])
        health += MSG[:invalid_env_image] if v['image'].nil?
        health += MSG[:invalid_env_port] unless v['port'].is_a?(Integer) || v['port'].nil?
        health += MSG[:invalid_env_runlist] if v['runlist'].nil? || v['runlist'].empty?
        health += MSG[:invalid_env_componentrole] unless v['componentrole'].include?('#') if v['componentrole']
        health += MSG[:env_component_mismatch] unless platform.components.include?(component)
      end
      health += MSG[:env_component_mismatch] unless platform.components.size == @components.size
      if health.length > 0
        puts health + "\n#{health.lines.count} environment offense(s) detected"
        false
      else
        true
      end
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity

    # Override to string-ify the environment
    # @return [String]
    def to_s
      puts @name
      puts @vcenter.to_yaml
      puts @components.to_yaml
      puts @nodenameconvention.to_yaml
    end

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity

    # Public: method to request provisioning of all or a portion
    # of the environment
    # @param [String] type What type of provisioning, `:all`, `:tier`, `:component`, or `:node`
    # @param [String] tier Name of the environment tier, when `type` is `:tier`
    # @param [String] component Name of component to provision, when `type` is `:component` or `:node`
    # @param [String] instance Numerical instance of the `component`, when `type` is `:node` (i.e., 1, 2, 3)
    # @param [String] options Thor-provided `options` hash
    def provision(type: :all, tier: nil, component: nil, instance: nil, options: nil)
      # Create the ProvisionerRunQueue to batch up our tasks
      runner = ProvisionerRunQueue.new

      # Modify behavior for dry-run (no concurrency)
      if !options['dry-run']
        runner.max_concurrent = options[:concurrency]
      else
        puts "Dry run requested, forcing concurrency to '1'."
        runner.max_concurrent = 1
      end

      @components.each do |component_name, component_data|
        next unless type.eql?(:all) || component_data['tier'].match(/\A#{tier.to_s}\z/i) || component_name.match(/\A#{component.to_s}\z/i)

        1.upto(component_data['addresses'].count) do |component_instance|
          next unless instance == component_instance || instance.nil?
          instance_name = node_name(component_name, component_instance)
          # Create the Provisioner
          provisioner = Elevage::Provisioner.new(instance_name, component_data, component_instance, self, options)
          # Add it to the queue
          runner.provisioners << provisioner
        end
      end

      runner.to_s if options['dry-run']

      # Process the queue
      runner.run
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity

    private

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity

    # Updates env hash with necessary info from Platform files.
    # This is a blend of env and Platform info needed to construct
    # Environment class object
    #
    # @param [String] env String passed from commend line, simple environment
    # name
    # @param [Hash] env_yaml Hash from requested environment.yml
    # @param [Elevage::Platform] platform Platform class object built from
    # standard platform definition files
    # @return [Hash] Updated env_yaml hash
    def build_env(env, env_yaml, platform)
      # substitute vcenter resources from vcenter.yml for location defined in environment file
      env_yaml['vcenter'] = platform.vcenter[env_yaml['vcenter']]
      # merge component resources from environment file and platform definition
      # platform info will be inserted where not found in env files, env overrides will be unchanged
      #
      # Note: this function does not do error checking for components that exist in env file but
      # not in Platform definition. Such files will be retained but not have any Platform
      # component info. The Build command will run error checking before building, but to support
      #  the debugging value of the list command only hash.merge! is performed at this point.
      platform.components.each do |component, _config|
        begin
          env_yaml['components'][component].merge!(platform.components[component]) { |_key, v1, _v2| v1 } unless env_yaml['components'][component].nil?
        rescue => error
          puts "ERROR: build_env: could not merge component \"#{component}\" for environment \"#{env}\"!"
          raise error
        end
      end
      # substitute network and components for specified values from platform definition files
      env_yaml['components'].each do |component, _config|
        env_yaml['components'][component]['network'] = platform.network[env_yaml['components'][component]['network']]
        env_yaml['components'][component]['compute'] = platform.compute[env_yaml['components'][component]['compute']]
        unless env_yaml['components'][component]['runlist'].nil?
          env_yaml['components'][component]['runlist'] = run_list(env_yaml['components'][component]['runlist'], env_yaml['components'][component]['componentrole'], component)
        end
      end
      unless env_yaml['vcenter'].nil?
        # append env name to destination folder if appendenv == true
        env_yaml['vcenter']['destfolder'] += (env_yaml['vcenter']['appendenv'] ? '/' + env.to_s : '')

        # prepend app name to domain if appenddomain == true
        # If 'appenddomain' is true, add the environment name as a subdomain.
        if env_yaml['vcenter']['appenddomain']
          env_yaml['vcenter']['domain'] = '.' + platform.name + '.' + env_yaml['vcenter']['domain']
        end

        # Make sure the domain has a leading '.' or things don't look right.
        env_yaml['vcenter']['domain'].sub!(/^/, '.') unless env_yaml['vcenter']['domain'].match(/^\./)

      end
      env_yaml
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity, PerceivedComplexity

    # rubocop:disable MethodLength

    # Construct a node hostname from parameters
    #
    # @param [Hash] component Hash, environment components
    # @param [integer] instance integer, passed from loop iterator
    # @return [String] hostname
    def node_name(component, instance)
      name = ''
      @nodenameconvention.each do |i|
        case i
        when 'environment'
          name += @name
        when 'component'
          name += component
        when 'instance'
          name += instance.to_s.rjust(2, '0')
        when 'geo'
          name += @vcenter['geo'].to_s[0]
        else
          name += i
        end
      end
      name
    end
    # rubocop:enable MethodLength

    # rubocop:disable LineLength

    # Constructs the node runlist from parameters
    #
    # @param [Array] list Array of strings from component runlist hash key
    # value
    # @param [String] componentrole String value from component, performs
    # simple string substitution of component string in component role string
    # @param [String] component Name of the component
    # @return [String] Chef runlist
    def run_list(list, componentrole, component)
      list.join(',') + (componentrole ? ',' + componentrole.gsub('#', component) : '')
    end
    # rubocop:enable LineLength

    # Ensure the environment file exists
    # @param [String] env_file Environment file name
    # @return [Boolean] True if `env_file` exists
    def env_file_exists?(env_file)
      fail(IOError, ERR[:no_environment_file]) unless File.file?(env_file)
      true
    end
  end
end
# rubocop:enable ClassLength
