require 'get_process_mem'

module PumaWorkerKiller
  class Reaper
    def initialize(max_ram)
      @max_ram = max_ram
      @master  = ObjectSpace.each_object(Puma::Cluster).map { |obj| obj }.first
    end

    def memory(pid)
      GetProcessMem.new(pid).mb
    end

    def reap
      puts "reaping master: #{@master.inspect}"
      return unless @master
      workers = {}
      @master.workers.each { |worker| workers[worker] = memory(worker.pid) }
      master_memory = memory(Process.pid)
      total_memory  = workers.map {|_, memory| memory }.inject(&:+) + master_memory

      if total_memory > @max_ram
        biggest_worker, memory_used = workers.sort_by {|_, mem| mem }.last
        biggest_worker.term
        puts "Out of memory. #{workers.count} workers consuming total: #{total_memory} mb out of max: #{@max_ram} mb. Sending TERM to #{biggest_worker.inspect} consuming #{memory_used} mb."
        Process.wait(biggest_worker.pid)
        reap # call again in case still out of memory
      end
    end
  end
end
