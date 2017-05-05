module PumaWorkerKiller
  class Reaper
    def initialize(max_ram, master = nil, reaper_status_logs = true, pre_term)
      @cluster = PumaWorkerKiller::PumaMemory.new(master)
      @max_ram = max_ram
      @reaper_status_logs = reaper_status_logs
      @pre_term = pre_term
    end

    # used for tes
    def get_total_memory
      @cluster.get_total_memory
    end

    def reap
      return false if @cluster.workers_stopped?
      if (total = get_total_memory) > @max_ram
        @cluster.master.log "PumaWorkerKiller: Out of memory. #{@cluster.workers.count} workers consuming total: #{total} mb out of max: #{@max_ram} mb. Sending TERM to pid #{@cluster.largest_worker.pid} consuming #{@cluster.largest_worker_memory} mb."

        # Fetch the largest_worker so that both `@pre_term` and `term_worker` are called with the same worker
        # Avoids a race condition where:
        #   Worker A consume 100 mb memory
        #   Worker B consume 99 mb memory
        #   pre_term gets called with Worker A
        #   A new request comes in, Worker B takes it, and consumes 101 mb memory
        #   term_largest_worker (previously here) gets called and terms Worker B (thus not passing the about-to-be-terminated worker to `@pre_term`)
        largest_worker = @cluster.largest_worker
        @pre_term.call(largest_worker)
        @cluster.term_worker(largest_worker)

      elsif @reaper_status_logs
        @cluster.master.log "PumaWorkerKiller: Consuming #{total} mb with master and #{@cluster.workers.count} workers."
      end
    end
  end
end
