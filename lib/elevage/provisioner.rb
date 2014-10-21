require_relative 'constants'
require_relative 'platform'

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

      # Get the knife command
      knife_cmd = generate_knife_cmd

      # If we're doing a dry-run, spit out the command and quit
      if @options['dry-run']
        puts "#{knife_cmd}\n\n"
        return
      end

      # Replace this with something that actually does something.
      # puts "#{knife_cmd}\n\n"
      # Figure out why this is barfing.
      system(knife_cmd)

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

  class ProvisionerRunQueue

    attr_reader :running_tasks
    attr_accessor :provisioners
    attr_accessor :max_concurrent
    attr_accessor :busy_wait_timeout

    # Public: Initialize the object
    def initialize

      # We start out with nothing running
      @running_tasks = 0

      # By default we'll run 4 things at once
      @max_concurrent = 4

      # We'll check if we can start a new child every half second
      @busy_wait_timeout = 0.5

      # Create an emtpy array for the Provisioners
      @provisioners = Array.new

    end

    # Public: run() - Process the queue
    def run

      # Hash to track our child processes with...
      # Key is PID of child process, value is node name of Provisioner
      children = Hash.new

      # Trap SIGCHLD so that the system can notify us whenever
      # one of our child processes terminates.
      trap("CLD") do
        pid = Process.wait
        @running_tasks -= 1
        children.delete(pid)
      end

      @provisioners.each do |prov|

        # Make sure we're not running more jobs than we're allowed
        wait_for_tasks children, :running

        # Start the provisioner in its own child process
        child_pid = fork do
          start_time = Time.now
          print "#{Time.now} [#$$]: #{prov.name} Provisioning...\n"
          prov.build
          # sleeptime = rand(120)
          # sleep sleeptime
          run_time = Time.now - start_time
          print "#{Time.now} [#$$]: #{prov.name} Completed in #{run_time.round(2)} seconds.\n"
        end
        children[child_pid] = prov.name

        @running_tasks += 1

      end

      # Hang around until we collect all the rest of the children
      wait_for_tasks children, :collect

    end

    private

    # Private: Wait for child tasks to return
    # Since our trap for SIGCHLD will clean up the @running_tasks count and
    # the children hash, here we can just keep checking until @running_tasks
    # is 0.
    # If we've been waiting at least a minute, print out a notice of what
    # we're still waiting for.
    def wait_for_tasks(children, state)
      # MAGIC NUMBER: Print a message at least once a minute (60 seconds)
      i = interval = 60/@busy_wait_timeout
      while @running_tasks >= @max_concurrent && state.eql?(:running) || @running_tasks > 0 && state.eql?(:collect) do
        if i <= 0
          print "#{Time.now} [#$$]: Waiting for #{children.size} jobs:\n"
          children.each do |pid, name|
            print " - #{pid}: #{name}\n"
          end
          i = interval
        end
        i -= 1
        sleep @busy_wait_timeout
      end
    end

  end
end
