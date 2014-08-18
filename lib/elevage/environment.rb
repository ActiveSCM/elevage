require 'yaml'

require_relative 'constants'

module Elevage
  # Environment class
  class Environment
    attr_accessor :name
    attr_accessor :vcenter
    attr_accessor :components
    attr_accessor :nodenameconvention

    def initialize(env, platform)
      environment = build_environment(env, YAML.load_file(ENVIRONMENTS_FOLDER +
                    env + '.yml').fetch('environment'), platform)
      @name = env
      @vcenter = environment['vcenter']
      @components = environment['components']
      @nodenameconvention = platform.nodenameconvention
    end

    def list_nodes
      puts @vcenter['destfolder']
      @components.each do |component, _config|
        (1..@components[component]['count']).each do |i|
          puts @components[component]['addresses'][i - 1].ljust(18, ' ') +
          node_name(component, i) + @vcenter['domain'] + '   ' +
                   @components[component]['runlist'].to_s
        end
      end
    end

    def to_s
      puts @name
      puts @vcenter.to_yaml
      puts @components.to_yaml
    end

    private

    # rubocop:disable all
    def build_environment(env, env_yaml, platform)
      # substitute vcenter resources
      env_yaml['vcenter'] = platform.vcenter['locations'][env_yaml['vcenter']]
      # merge component resources from environment file and platform definition
      platform.components.each do |component, _config|
        env_yaml['components'][component].merge!(platform.components[component]) { |_key, v1, _v2| v1 }
      end
      # substitute network and components with key values
      env_yaml['components'].each do |component, _config|
        env_yaml['components'][component]['network'] = platform.network[env_yaml['components'][component]['network']]
        env_yaml['components'][component]['compute'] = platform.compute['options'][env_yaml['components'][component]['compute']]
        env_yaml['components'][component]['runlist'] = run_list(env_yaml['components'][component]['runlist'],env_yaml['components'][component]['componentrole'], component)
      end
      # append env name to dest folder if appendenv == true
      env_yaml['vcenter']['destfolder'] += (env_yaml['vcenter']['appendenv'] ? '/' + env.to_s : '')
      # prepend app name to domain if appenddomain == true
      env_yaml['vcenter']['appenddomain'] ? env_yaml['vcenter']['domain'] = '.' + platform.name + '.' + env_yaml['vcenter']['domain'] : ''
      env_yaml
    end
    # rubocop:enable all

    # rubocop:disable all
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
    # rubocop:enable all

    def run_list(list, componentrole, component)
      list.join(',') + (componentrole ? ',' + componentrole.gsub('#', component) : '')
    end
  end
end
