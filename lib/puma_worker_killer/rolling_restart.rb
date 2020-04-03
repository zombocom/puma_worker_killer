module PumaWorkerKiller
  class RollingRestart
    def initialize(master = nil)
      @cluster = PumaWorkerKiller::PumaMemory.new(master)
    end

    # used for tes
    def get_total_memory
      @cluster.get_total_memory
    end

    def reap(wait_between_worker_kill = 60) # seconds
      # this will implicitly call set_workers
      total_memory = get_total_memory
      return false unless @cluster.running?

      @cluster.workers.each do |worker, _ram|
        @cluster.master.log "PumaWorkerKiller: Rolling Restart. #{@cluster.workers.count} workers consuming total: #{total_memory} mb. Sending TERM to pid #{worker.pid}."
        worker.term
        sleep wait_between_worker_kill
      end
    end
  end
end
