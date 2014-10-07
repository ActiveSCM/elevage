require_relative 'constants'
require_relative 'platform'

module Elevage
  class Provisioner

    attr_accessor :name
    attr_accessor :component
    attr_accessor :instance
    attr_accessor :environment
    attr_accessor :vcenter
    attr_accessor :username
    attr_accessor :password

    def initialize(name, component, instance, environment)

      @name = name
      @component = component
      @instance = instance
      @environment = environment
      @vcenter = @environment.vcenter
      @username = ENV['ELEVAGE_USER'] || ENV['USER']
      @password = ENV['ELEVAGE_PASSWORD'] || 'changeme'

    end

    def to_s
      puts "Name: " << @name
      puts "Instance: " << @instance
      puts @component.to_yaml
      puts @environment.to_yaml
      puts "User: " << @username
      puts "Password: " << @password
    end

    # It'll all eventually boil down to building a massive 'knife vsphere' command
    def build_knife_cmd

      knife_cmd = "knife vsphere vm clone"

      # -----
      # vsphere options
      knife_cmd << " --vsuser #{@username}"
      knife_cmd << " --vspass #{@password}"
      knife_cmd << " --vshost #{@vcenter['host']}"
      knife_cmd << " --vsdc '#{@vcenter['datacenter']}'"
      knife_cmd << " --dest-folder '#{@vcenter['destfolder']}'"
      knife_cmd << " --datastore '#{@vcenter['datastores'][rand(@vcenter['datastores'].count)]}'"
      knife_cmd << " --cvlan '#{@component['network']['vlanid']}'"
      knife_cmd << " --cips '#{@component['addresses'][@instance - 1]}'"
      knife_cmd << " --cdnsips '#{@vcenter['dnsips'].join(' ')}'"
      knife_cmd << " --cgw '#{@component['network']['gateway']}'"
      knife_cmd << " --chostname #{@name}"

      domain = @vcenter['domain']
      domain = domain[1, domain.length] if domain.start_with?('.')
      knife_cmd << " --cdomain " << domain
      knife_cmd << " --cdnssuffix " << domain

      knife_cmd << " --ctz #{@vcenter['timezone'].to_s}"
      knife_cmd << " --ccpu #{@component['compute']['cpu'].to_s}"
      knife_cmd << " --cram #{@component['compute']['ram'].to_s}"
      knife_cmd << " --start --vsinsecure"
      knife_cmd << " --folder '#{@vcenter['destfolder']}'"
      knife_cmd << " --template '#{@component['image']}'"
      knife_cmd << " --resource-pool '#{@vcenter['resourcepool']}'"


      knife_cmd << " --bootstrap"
      knife_cmd << " --template-file $templatefile"
      knife_cmd << " --fqdn #{@component['addresses'][@instance - 1]}"
      knife_cmd << " --ssh-user knife"
      knife_cmd << " --identity-file $identityfile"

      nodename = @name
      nodename << @environment.name if @vcenter['appendenv']
      nodename << @vcenter['domain'] if @vcenter['appenddomain']
      knife_cmd << " --node-name " << nodename

      knife_cmd << " --run-list " << @component['runlist']
      knife_cmd << " --environment " << @environment.name
      knife_cmd << " --bootstrap-version $bootstrapversion"
      knife_cmd << " #{nodename}"

      # spit the command line out for now
      puts knife_cmd
      puts ""

      # Assert
      knife_cmd

    end

  end
end