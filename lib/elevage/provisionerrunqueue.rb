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
      @max_concurrent = BUILD_CONCURRENT_DEFAULT

      # We'll check if we can start a new child every half second
      @busy_wait_timeout = BUILD_CHILD_WAIT_TIMEOUT

      # How often we'll give a status update if nothing is happening
      @build_status_interval = BUILD_STATUS_INTERVAL

      # Create an emtpy array for the Provisioners
      @provisioners = Array.new

      # Hash to track our child processes with...
      # Key is PID of child process, value is node name of Provisioner
      @children = Hash.new

    end

    # Public: run() - Process the queue
    def run
      @provisioners.each do |provisioner|
        # Make sure we're not running more jobs than we're allowed
        wait_for_tasks :running
        child_pid = fork do
          provision_task(provisioner)
        end
        @children[child_pid] = provisioner.name
        @running_tasks += 1
      end
      # Hang around until we collect all the rest of the children
      wait_for_tasks :collect
      puts "#{Time.now} [#{$$}]: Provisioning completed."
    end

    # Public: Display a string representation
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
      print "#{Time.now} [#$$]: #{task.name} Provisioning...\n"
      status = task.build ? 'succeeded' : 'FAILED'
      # status = sleep(rand(120)) != 0 ? 'succeeded' : 'FAILED' # testing process handling
      run_time = Time.now - start_time
      print "#{Time.now} [#$$]: #{task.name} #{status} in #{run_time.round(2)} seconds.\n"
    end

    # Private: Wait for child tasks to return
    # Since our trap for SIGCHLD will clean up the @running_tasks count and
    # the children hash, here we can just keep checking until @running_tasks
    # is 0.
    # If we've been waiting at least a minute, print out a notice of what
    # we're still waiting for.
    def wait_for_tasks(state)

      i = interval = @build_status_interval/@busy_wait_timeout

      # We are either "running", and waiting for a child to return so we can
      # dispatch a new child, or we are "collecting", in which case we have
      # no more children waiting to be dispatched, and are waiting for them
      # all to finish.
      while @running_tasks >= @max_concurrent && state.eql?(:running) || @running_tasks > 0 && state.eql?(:collect) do

        # Always having to clean up after our children...
        @children.keys.each do |pid|
          childpid = Process.wait(pid, Process::WNOHANG|Process::WUNTRACED)
          unless childpid.nil?
            @children.delete(childpid)
            @running_tasks -= 1
          end
        end

        # Is it time for a status update yet?
        if i <= 0
          print "#{Time.now} [#$$]: Waiting for #{@children.size} jobs:\n"
          @children.each do |pid, name|
            print " - #{pid}: #{name}\n"
          end
          # reset the status counter
          i = interval
        end

        # tick the status counter
        i -= 1
        sleep @busy_wait_timeout

      end

    end

  end

end