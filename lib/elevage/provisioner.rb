require_relative 'constants'
require_relative 'platform'
require_relative 'provisionerrunqueue'
require 'thread'
require 'open4'

module Elevage
  class Provisioner

    attr_accessor :name
    attr_accessor :component
    attr_accessor :instance
    attr_accessor :environment
    attr_accessor :vcenter

    # Set us up to build the specified instance of component
    def initialize(name, component, instance, environment, options)

      @name = name
      @component = component
      @instance = instance
      @environment = environment
      @options = options
      @vcenter = @environment.vcenter

    end

    def to_s
      puts "Name: #{@name}"
      puts "Instance: #{@instance}"
      puts "Component: #{@component}"
      puts @component.to_yaml
      puts 'Environment:'
      puts @environment.to_yaml
    end

    # Public: Build the node
    def build

      knife_cmd = generate_knife_cmd


      # Modify behavior for dry-run
      # Echo command to stdout and logfile instead of executing command.
      if @options['dry-run']
        puts "#{knife_cmd}"
        knife_cmd = "echo #{knife_cmd}"
      end

      # Open the logfile for writing
      logfile = File.new("#{@options[:logfiles]}/#{@name}.log",'w')
      puts "#{Time.now} [#{$$}]: #{@name}: logging to #{logfile.path}"
      logfile.puts "#{Time.now} [#{$$}]: #{@name}: Provisioning."

      # Execute the knife command, capturing stderr and stdout as they
      # produce anything, and push it all into a Queue object, which we then
      # write to the log file as things come available.
      status = Open4.popen4(knife_cmd) do |pid, stdin, stdout, stderr|
        sem = Mutex.new
        err_thread = Thread.new do
          while (line = stderr.gets)
            sem.synchronize { logfile.puts "#{Time.now} [#{$$}]: #{line}" }
          end
        end
        out_thread = Thread.new do
          while (line = stdout.gets)
            sem.synchronize { logfile.puts "#{Time.now} [#{$$}]: #{line}" }
          end
        end
        out_thread.join
        # err_thread.exit
      end

      logfile.puts "#{Time.now} [#{$$}]: #{@name}: status: #{status}"
      logfile.close

      # Pass on the knife command's exit status as ours
      true unless status.exitstatus

    end

    private

    # Private: Build the knife command that will do the provisioning.
    def generate_knife_cmd

      knife_cmd = "knife vsphere vm clone --vsinsecure --start"

      # Authentication and host
      knife_cmd << " --vsuser #{@options[:vsuser]}"
      knife_cmd << " --vspass #{@options[:vspass]}"
      knife_cmd << " --vshost #{@vcenter['host']}"

      # VM Template (what we're cloning)
      knife_cmd << " --folder '#{@vcenter['imagefolder']}'"
      knife_cmd << " --template '#{@component['image']}'"

      # vSphere destination information (where the clone will end up)
      knife_cmd << " --vsdc '#{@vcenter['datacenter']}'"
      knife_cmd << " --dest-folder '#{@vcenter['destfolder']}'"
      knife_cmd << " --datastore '#{@vcenter['datastores'][rand(@vcenter['datastores'].count)]}'"
      knife_cmd << " --resource-pool '#{@vcenter['resourcepool']}'"

      # VM Hardware
      knife_cmd << " --ccpu #{@component['compute']['cpu'].to_s}"
      knife_cmd << " --cram #{@component['compute']['ram'].to_s}"

      # VM Networking
      knife_cmd << " --cvlan '#{@component['network']['vlanid']}'"
      knife_cmd << " --cips #{@component['addresses'][@instance - 1]}/#{@component['network']['netmask']}"
      knife_cmd << " --cdnsips #{@vcenter['dnsips'].join(',')}"
      knife_cmd << " --cgw #{@component['network']['gateway']}"
      knife_cmd << " --chostname #{@name}"
      knife_cmd << " --ctz #{@vcenter['timezone'].to_s}"

      # AD Domain and DNS Suffix
      domain = @vcenter['domain']
      domain = domain[1, domain.length] if domain.start_with?('.')
      knife_cmd << " --cdomain #{domain}"
      knife_cmd << " --cdnssuffix #{domain}"

      # Knife Bootstrap options
      knife_cmd << " --bootstrap"
      knife_cmd << " --template-file '#{@options['template-file']}'"

      # knife fqdn specifies how knife will connect to the target (in this case by IP)
      knife_cmd << " --fqdn #{@component['addresses'][@instance - 1]}"
      knife_cmd << " --ssh-user #{@options['ssh-user']}"
      knife_cmd << " --identity-file '#{@options['ssh-key']}'"

      # What the node should be identified as in Chef
      nodename = String.new(@name)
      nodename << '.' << @environment.name if @vcenter['appendenv']
      nodename << @vcenter['domain'] if @vcenter['appenddomain']
      knife_cmd << " --node-name '#{nodename}'"

      # Assign the run_list
      knife_cmd << " --run-list '#{@component['runlist']}'"

      # Assign the Chef environment
      knife_cmd << " --environment '#{@environment.name}'"

      # What version of chef-client are we bootstrapping (not sure this is necessary)
      knife_cmd << " --bootstrap-version #{@options['bootstrap-version']}"

      # Finally, the name of the VM as seen by vSphere.
      # Whereas nodename will optionally append the domain name, VM names should *always* have the domain name
      # appended. The only optional bit is including the chef environment in the name.
      vmname = String.new(@name)
      vmname << '.' << @environment.name if @vcenter['appendenv']
      vmname << @vcenter['domain']
      knife_cmd << " #{vmname}"

      # Assert
      knife_cmd

    end

  end

end
