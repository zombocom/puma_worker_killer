module PumaWorkerKiller
  class Reaper
    def initialize(max_ram, master = nil)
      @cluster = PumaWorkerKiller::PumaMemory.new(master)
      @max_ram = max_ram
    end

    # used for tes
    def get_total_memory
      @cluster.get_total_memory
    end

    def reap
      return false if @cluster.workers_stopped?
      if (total = get_total_memory) > @max_ram
        @cluster.master.log "PumaWorkerKiller: Out of memory. #{@cluster.workers.count} workers consuming total: #{total} mb out of max: #{@max_ram} mb. Sending TERM to pid #{@cluster.largest_worker.pid} consuming #{@cluster.largest_worker_memory} mb."
        @cluster.term_largest_worker
      else
        @cluster.master.log "PumaWorkerKiller: Consuming #{total} mb with master and #{@cluster.workers.count} workers."
      end
    end
  end
end
