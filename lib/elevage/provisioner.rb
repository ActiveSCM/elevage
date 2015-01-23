require 'thread'
require 'open4'
require_relative 'constants'
require_relative 'platform'
require_relative 'provisionerrunqueue'

module Elevage
  # rubocop:disable ClassLength

  # Provisioner is responsible for the actual execution of the commands to
  # create the requested virtual machine.
  class Provisioner
    attr_accessor :name
    attr_accessor :component
    attr_accessor :instance
    attr_accessor :environment
    attr_accessor :vcenter

    # Create the Provisioner object for the requested virtual machine
    # @param [String] name Name of the node to create
    # @param [String] component Name of the platform component node is part of
    # @param [String] instance Number representing which instance of
    # `component` this node is
    # @param [String] environment Name of the environnment we're provisioning to
    # @param [String] options Thor `options` hash
    # @return [Elevage::Provisioner]
    def initialize(name, component, instance, environment, options)
      @name = name
      @component = component
      @instance = instance
      @environment = environment
      @options = options
      @vcenter = @environment.vcenter
    end

    # Stringify the Provisioner
    # @return [String]
    def to_s
      puts "Name: #{@name}"
      puts "Instance: #{@instance}"
      puts "Component: #{@component}"
      puts @component.to_yaml
      puts 'Environment:'
      puts @environment.to_yaml
    end

    # rubocop:disable MethodLength, LineLength, GlobalVars, CyclomaticComplexity

    # Build the the virtual machine
    def build
      knife_cmd = generate_knife_cmd

      # Modify behavior for dry-run
      # Echo command to stdout and logfile instead of executing command.
      if @options['dry-run']
        puts knife_cmd
        knife_cmd = "echo #{knife_cmd}"
      end

      # Open the logfile for writing
      logfile = File.new("#{@options[:logfiles]}/#{@name}.log", 'w')

      stamp = @options['dry-run'] ? '' : "#{Time.now} [#{$$}]: "
      puts "#{stamp}#{@name}: logging to #{logfile.path}"
      logfile.puts "#{stamp}#{@name}: Provisioning."

      # Execute the knife command, capturing stderr and stdout as they
      # produce anything, and push it all into a Queue object, which we then
      # write to the log file as things come available.
      status = Open4.popen4(knife_cmd) do |_pid, _stdin, stdout, stderr|
        sem = Mutex.new
        # Set and forget the thread for stderr...
        # err_thread = Thread.new do
        Thread.new do
          while (line = stderr.gets)
            sem.synchronize do
              logfile.puts line
              logfile.sync
            end
          end
        end
        out_thread = Thread.new do
          while (line = stdout.gets)
            sem.synchronize do
              logfile.puts line
              logfile.sync
            end
          end
        end
        out_thread.join
        # err_thread.exit
      end

      stamp = @options['dry-run'] ? '' : "#{Time.now} [#{$$}]: "
      logfile.puts "#{stamp}#{@name}: exit status: #{status.exitstatus}"
      logfile.close

      # Inform our master whether we succeeded or failed. Any non-zero
      # exit status is a failure, and the details will be in the logfile
      status.exitstatus == 0 ? true : false
    end
    # rubocop:enable MethodLength, LineLength, GlobalVars, CyclomaticComplexity

    private

    # rubocop:disable LineLength

    # Private
    #
    # Determine which datastore to use for this specific provisioning.
    # @return [String] Name of datastore
    def select_datastore
      knife_cmd = 'knife vsphere datastore maxfree --vsinsecure'

      # Authentication and host
      knife_cmd << " --vsuser #{@options[:vsuser]}"
      knife_cmd << " --vspass #{@options[:vspass]}"
      knife_cmd << " --vshost #{@vcenter['host']}"

      # vSphere destination information (where the clone will end up)
      knife_cmd << " --vsdc '#{@vcenter['datacenter']}'"

      # datastore prefix
      knife_cmd << " --regex #{@vcenter['datastore']}"

      # get result and clean up
      @options['dry-run'] ? @vcenter['datastore'] : `#{knife_cmd}`.to_s.gsub!("\n", '')
    end
    # rubocop:enable LineLength

    # rubocop:disable MethodLength, LineLength

    # Private
    #
    # Build the knife command that will do the provisioning.
    # @return [String] knife command line string
    def generate_knife_cmd
      knife_cmd = 'knife vsphere vm clone --vsinsecure --start'

      # Authentication and host
      knife_cmd << " --vsuser #{@options[:vsuser]}"
      knife_cmd << " --vspass #{@options[:vspass]}"
      knife_cmd << " --vshost #{@vcenter['host']}"

      # VM Template (what we're cloning)
      knife_cmd << " --folder '#{@vcenter['imagefolder']}'"
      knife_cmd << " --template '#{@component['image']}'"

      # vSphere destination information (where the clone will end up)
      knife_cmd << " --vsdc '#{@vcenter['datacenter']}'"
      knife_cmd << " --dest-folder '#{@vcenter['destfolder']}"
      knife_cmd << "/#{@component['tier']}" if @vcenter['appendtier']
      knife_cmd << '\''
      knife_cmd << " --resource-pool '#{@vcenter['resourcepool']}'"
      knife_cmd << " --datastore '#{select_datastore}'"

      # VM Hardware
      knife_cmd << " --ccpu #{@component['compute']['cpu']}"
      knife_cmd << " --cram #{@component['compute']['ram']}"

      # VM Networking
      knife_cmd << " --cvlan '#{@component['network']['vlanid']}'"
      knife_cmd << " --cips #{@component['addresses'][@instance - 1]}/#{@component['network']['netmask']}"
      knife_cmd << " --cdnsips #{@vcenter['dnsips'].join(',')}"
      knife_cmd << " --cgw #{@component['network']['gateway']}"
      knife_cmd << " --chostname #{@name}"
      knife_cmd << " --ctz #{@vcenter['timezone']}"

      # AD Domain and DNS Suffix
      domain = @vcenter['domain']
      domain = domain[1, domain.length] if domain.start_with?('.')
      knife_cmd << " --cdomain #{domain}"
      knife_cmd << " --cdnssuffix #{domain}"

      # Knife Bootstrap options
      knife_cmd << ' --bootstrap'
      knife_cmd << " --template-file '#{@options['template-file']}'"

      # knife fqdn specifies how knife will connect to the target (in this case by IP)
      knife_cmd << " --fqdn #{@component['addresses'][@instance - 1]}"
      knife_cmd << " --ssh-user #{@options['ssh-user']}"
      knife_cmd << " --identity-file '#{@options['ssh-key']}'"

      # What the node should be identified as in Chef
      nodename = String.new(@name)
      nodename << @vcenter['domain'] if @vcenter['appenddomain']
      knife_cmd << " --node-name '#{nodename}'"

      # Assign the run_list
      knife_cmd << " --run-list '#{@component['runlist']}'"

      # Assign the Chef environment
      knife_cmd << " --environment '#{@environment.name}'"

      # What version of chef-client are we bootstrapping (not sure
      # this is necessary)
      knife_cmd << " --bootstrap-version #{@options['bootstrap-version']}"

      # Finally, the name of the VM as seen by vSphere.
      # Whereas nodename will optionally append the domain name, VM names
      # should *always* have the domain name appended.
      vmname = String.new(@name)
      vmname << @vcenter['domain']
      knife_cmd << " #{vmname}"
    end
    # rubocop:enable MethodLength, LineLength
  end
  # rubocop:enable ClassLength
end
