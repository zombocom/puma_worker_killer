require 'get_process_mem'
require 'puma/cluster'

module PumaWorkerKiller
  class Reaper
    def initialize(max_ram, master = self.get_master)
      @max_ram = max_ram
      @master  = master
    end

    def get_master
      ObjectSpace.each_object(Puma::Cluster).map { |obj| obj }.first
    end

    def get_memory(pid)
      GetProcessMem.new(pid).mb
    end

    def get_workers
      workers = {}
      @master.instance_variable_get("@workers").each { |worker| workers[worker] = get_memory(worker.pid) }
      workers
    end

    def get_total_memory(workers = self.get_workers)
      master_memory = get_memory(Process.pid)
      worker_memory = workers.map {|_, mem| mem }.inject(&:+) || 0
      worker_memory + master_memory
    end

    def reap
      return false unless @master
      workers      = get_workers
      total_memory = get_total_memory(workers)
      if workers.any? && total_memory > @max_ram
        biggest_worker, memory_used = workers.sort_by {|_, mem| mem }.last
        biggest_worker.term
        @master.log "PumaWorkerKiller: Out of memory. #{workers.count} workers consuming total: #{total_memory} mb out of max: #{@max_ram} mb. Sending TERM to #{biggest_worker.inspect} consuming #{memory_used} mb."
        Process.wait(biggest_worker.pid)
      end
    end
  end
end
