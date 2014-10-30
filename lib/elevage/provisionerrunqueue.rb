require 'english'
require_relative 'constants'

module Elevage
  # ProvisionerRunQueue class
  class ProvisionerRunQueue
    attr_reader :running_tasks
    attr_accessor :provisioners
    attr_accessor :max_concurrent
    attr_accessor :busy_wait_timeout
    attr_accessor :build_status_interval

    # Public: Initialize the object
    def initialize
      @running_tasks = 0 # We start out with nothing running
      @max_concurrent = BUILD_CONCURRENT_DEFAULT
      @busy_wait_timeout = BUILD_CHILD_WAIT_TIMEOUT
      @build_status_interval = BUILD_STATUS_INTERVAL
      @provisioners = []
      @children = {}
    end

    # Public: run() - Process the queue
    def run
      @provisioners.each do |provisioner|
        # Make sure we're not running more jobs than we're allowed
        wait_for_tasks
        child_pid = fork do
          provision_task task: provisioner
        end
        @children[child_pid] = provisioner.name
        @running_tasks += 1
      end
      # Hang around until we collect all the rest of the children
      wait_for_tasks state: :collect
      puts "#{Time.now} [#{$PROCESS_ID}]: Provisioning completed."
    end

    # Public: Display a string representation
    # rubocop:disable MethodLength
    def to_s
      puts "Running Tasks: #{@running_tasks}"
      puts "Max Concurrency: #{@max_concurrent}"
      puts "Wait status interval: #{@build_status_interval}"
      puts 'Current Child processes:'
      @children.each do |pid, name|
        puts " - [#{pid}]: #{name}"
      end
      puts 'Queued Provisioners:'
      @provisioners.each do |provisioner|
        puts " - #{provisioner.name}"
      end
    end
    # rubocop:enable MethodLength

    private

    # rubocop:disable LineLength
    # Private: provision_task is the method that should execute in the child
    # process, and contain all the logic for the child process.
    def provision_task(task: nil)
      start_time = Time.now
      print "#{Time.now} [#{$PROCESS_ID}]: #{task.name} Provisioning...\n"
      status = task.build ? 'succeeded' : 'FAILED'
      run_time = Time.now - start_time
      print "#{Time.now} [#{$PROCESS_ID}]: #{task.name} #{status} in #{run_time.round(2)} seconds.\n"
    end
    # rubocop:enable LineLength

    # rubocop:disable MethodLength, LineLength, CyclomaticComplexity
    # Private: Wait for child tasks to return
    # Since our trap for SIGCHLD will clean up the @running_tasks count and
    # the children hash, here we can just keep checking until @running_tasks
    # is 0.
    # If we've been waiting at least a minute, print out a notice of what
    # we're still waiting for.
    def wait_for_tasks(state: :running)
      i = interval = @build_status_interval / @busy_wait_timeout

      # We are either "running", and waiting for a child to return so we can
      # dispatch a new child, or we are "collecting", in which case we have
      # no more children waiting to be dispatched, and are waiting for them
      # all to finish.
      while @running_tasks >= @max_concurrent && state.eql?(:running) || @running_tasks > 0 && state.eql?(:collect)

        # Always having to clean up after our children...
        @children.keys.each do |pid|
          childpid = Process.wait(pid, Process::WNOHANG | Process::WUNTRACED)
          unless childpid.nil?
            @children.delete(childpid)
            @running_tasks -= 1
          end
        end

        # Is it time for a status update yet?
        if i <= 0
          print "#{Time.now} [#{$PROCESS_ID}]: Waiting for #{@children.size} jobs:\n"
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
    # rubocop:enable MethodLength, LineLength, CyclomaticComplexity
  end
end
