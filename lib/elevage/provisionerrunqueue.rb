require_relative 'constants'

module Elevage

  class ProvisionerRunQueue

    attr_reader :running_tasks
    attr_accessor :provisioners
    attr_accessor :max_concurrent
    attr_accessor :busy_wait_timeout
    attr_accessor :build_status_interval

    # Public: Initialize the object
    def initialize

      # We start out with nothing running
      @running_tasks = 0

      # By default we'll run 4 things at once
      @max_concurrent = 4

      # We'll check if we can start a new child every half second
      @busy_wait_timeout = 0.5

      # How often we'll give a status update if nothing is happening
      @build_status_interval = 60

      # Create an emtpy array for the Provisioners
      @provisioners = Array.new

    end

    # Public: run() - Process the queue
    def run

      # Hash to track our child processes with...
      # Key is PID of child process, value is node name of Provisioner
      children = Hash.new

      # Spin each provisioner into its own process
      @provisioners.each do |provisioner|

        # Make sure we're not running more jobs than we're allowed
        wait_for_tasks children, :running

        # Start the provisioner in its own child process
        child_pid = fork do
          provision_task(provisioner)
        end
        children[child_pid] = provisioner.name

        @running_tasks += 1

      end

      # Hang around until we collect all the rest of the children
      wait_for_tasks children, :collect

    def to_s
      puts "Running Tasks: #{@running_tasks}"
      puts "Max Concurrency: #{@max_concurrent}"
      puts "Wait status interval: #{@build_status_interval}"
      puts "Current Child processes:"
      @children.each do |pid, name|
        puts " - [#{pid}]: #{name}"
      end
      puts "Queued Provisioners:"
      @provisioners.each do |provisioner|
        puts " - #{provisioner.name}"
      end
    end

    private

    # Private: provision_task is the method that should execute in the child
    # process, and contain all the logic for the child process.
    def provision_task (provisioner)
      start_time = Time.now
      print "#{Time.now} [#$$]: #{provisioner.name} Provisioning...\n"
      status = provisioner.build ? 'succeeded' : 'FAILED'
      # status = sleep(rand(5)) != 0 ? 'succeeded' : 'FAILED'
      run_time = Time.now - start_time
      print "#{Time.now} [#$$]: #{provisioner.name} #{status} in #{run_time.round(2)} seconds.\n"
    end

    # Private: Wait for child tasks to return
    # Since our trap for SIGCHLD will clean up the @running_tasks count and
    # the children hash, here we can just keep checking until @running_tasks
    # is 0.
    # If we've been waiting at least a minute, print out a notice of what
    # we're still waiting for.
    def wait_for_tasks(children, state)
      # MAGIC NUMBER: Print a message at least once a minute (60 seconds)
      i = interval = @build_status_interval/@busy_wait_timeout
      while @running_tasks >= @max_concurrent && state.eql?(:running) || @running_tasks > 0 && state.eql?(:collect) do

        # Check to see if any of our children should be reaped
        @children.each do |pid, name|
          childpid = Process.wait(pid, Process::WNOHANG|Process::WUNTRACED)
          unless childpid.nil?
            @children.delete(childpid)
            @running_tasks -= 1
          end
        end

        # Is it time for a status update yet?
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