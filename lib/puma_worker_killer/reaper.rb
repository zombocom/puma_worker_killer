module PumaWorkerKiller
  class Reaper
    def initialize(max_ram, master = self.get_master)
      @puma    = PumaWorkerKiller::PumaMemory.new(master)
      @max_ram = max_ram
    end

    def wait(pid)
      Process.wait(pid)
    rescue Errno::ECHILD
    end

    # used for tes
    def get_total_memory
      @puma.get_total_memory
    end

    def reap
      return false unless @puma.running?
      if (total = get_total_memory) > @max_ram
        @puma.master.log "PumaWorkerKiller: Out of memory. #{@puma.workers.count} workers consuming total: #{total} mb out of max: #{@max_ram} mb. Sending TERM to #{@puma.largest_worker.inspect} consuming #{@puma.largest_worker_memory} mb."
        @puma.largest_worker.term
        wait(@puma.largest_worker.pid)
      else
        @puma.master.log "PumaWorkerKiller: Consuming #{total} mb with master and #{@puma.workers.count} workers"
      end
    end
  end
end
