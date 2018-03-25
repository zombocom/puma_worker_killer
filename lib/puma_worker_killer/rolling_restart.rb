module PumaWorkerKiller
  class RollingRestart
    # Reap workers with an optional delay between terminations
    # to avoid all workers being killed at once.
    def initialize(kill_delay = 60, master = nil)
      @cluster = PumaWorkerKiller::PumaMemory.new(master)
      @kill_delay = kill_delay
    end

    # used for tes
    def get_total_memory
      @cluster.get_total_memory
    end

    def reap
      return false unless @cluster.running?
      @cluster.workers.each do |worker, ram|
        @cluster.master.log "PumaWorkerKiller: Rolling Restart. #{@cluster.workers.count} workers consuming total: #{ get_total_memory } mb. Sending TERM to pid #{worker.pid}."
        worker.term
        sleep @kill_delay
      end
    end
  end
end
