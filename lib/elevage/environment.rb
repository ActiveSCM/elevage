require 'yaml'
require 'resolv'

require_relative 'constants'
require_relative 'platform'

module Elevage
  # Environment class
  class Environment
    attr_accessor :name
    attr_accessor :vcenter
    attr_accessor :components
    attr_accessor :nodenameconvention

    # rubocop:disable LineLength, MethodLength
    def initialize(env)
      envfile = ENV_FOLDER + env.to_s + '.yml'
      if env_file_exists?(envfile)
        platform = Elevage::Platform.new
        if platform.environments.include?(env)
          environment = build_environment(env, YAML.load_file(envfile).fetch('environment'), platform)
          @name = env
          @vcenter = environment['vcenter']
          @components = environment['components']
          @nodenameconvention = platform.nodenameconvention
        else
          fail(IOError, ERROR_MSG[:environment_not_defined])
        end
      end
    end
    # rubocop:enable LineLength, MethodLength

    # Public: Environment class method that returns list of all nodes, including ips and runlist
    # Returns multiline string
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

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity
    def healthy?
      platform = Elevage::Platform.new
      health = ''
      health += HEALTH_MSG[:invalid_env_vcenter] if @vcenter.nil?
      @components.each do |component, v|
        health += HEALTH_MSG[:invalid_env_network] if v['network'].nil?
        health += HEALTH_MSG[:invalid_env_count] unless (0..POOL_LIMIT).member?(v['count'])
        health += HEALTH_MSG[:invalid_env_compute] if v['compute'].nil?
        health += HEALTH_MSG[:invalid_env_ip] if v['count'] != v['addresses'].size
        if v['addresses'].nil?
          health += HEALTH_MSG[:invalid_env_ip]
        else
          v['addresses'].each { |ip| health += HEALTH_MSG[:invalid_env_ip] unless Resolv::IPv4::Regex.match(ip) }
        end
        health += HEALTH_MSG[:invalid_env_tier] unless platform.tiers.include?(v['tier'])
        health += HEALTH_MSG[:invalid_env_image] if v['image'].nil?
        health += HEALTH_MSG[:invalid_env_port] unless v['port'].kind_of?(Integer) || v['port'].nil?
        health += HEALTH_MSG[:invalid_env_runlist] if v['runlist'].nil? || v['runlist'].empty?
        health += HEALTH_MSG[:invalid_env_componentrole] unless v['componentrole'].include?('#') if v['componentrole']
        health += HEALTH_MSG[:env_component_mismatch] unless platform.components.include?(component)
      end
      health += HEALTH_MSG[:env_component_mismatch] unless platform.components.size == @components.size
      if health.length > 0
        puts health + "\n#{health.lines.count} environment offense(s) detected"
        false
      else
        true
      end
    end
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity

    # Public: basic class puts string output
    def to_s
      puts @name
      puts @vcenter.to_yaml
      puts @components.to_yaml
      puts @nodenameconvention.to_yaml
    end

    private

    # Private: updates env hash with necessary info from Platform files.
    # This is a blend of env and Platform info needed to construct Environment class object
    #
    # Params
    #   env: string passed from commend line, simple environment name
    #   env_yaml: hash from requested environment.yml
    #   platform: Platform class object built from standard platform definition files
    #
    # Returns Hash: updated env_yaml hash
    # rubocop:disable MethodLength, LineLength
    def build_environment(env, env_yaml, platform)
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
        env_yaml['components'][component].merge!(platform.components[component]) { |_key, v1, _v2| v1 } unless env_yaml['components'][component].nil?
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
        env_yaml['vcenter']['appenddomain'] ? env_yaml['vcenter']['domain'] = '.' + platform.name + '.' + env_yaml['vcenter']['domain'] : ''
      end
      env_yaml
    end
    # rubocop:enable MethodLength, LineLength

    # Private: construct a node hostname from parameters
    #
    # Params
    #   component: Hash, environment components
    #   instance: integer, passed from loop iterator
    #
    # Returns hostname as String
    # rubocop:disable MethodLength
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

    # Private: Constructs the node runlist from parameters
    #
    # Params
    #   list: Array of string from component runlist hash key value
    #   componentrole:  String value from component, performs simple string substitution
    #                   of for component string in component role string
    #   component: String, component name
    #
    # Returns runlist as String
    def run_list(list, componentrole, component)
      list.join(',') + (componentrole ? ',' + componentrole.gsub('#', component) : '')
    end

    def env_file_exists?(env_file)
      fail(IOError, ERROR_MSG[:no_environment_file]) unless File.file?(env_file)
      true
    end
  end
end

