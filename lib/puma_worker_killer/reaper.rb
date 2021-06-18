# frozen_string_literal: true

module PumaWorkerKiller
  class Reaper
    def initialize(max_ram, master = nil, reaper_status_logs = true, pre_term = nil, on_calculation = nil)
      @cluster = PumaWorkerKiller::PumaMemory.new(master)
      @max_ram = max_ram
      @reaper_status_logs = reaper_status_logs
      @pre_term = pre_term
      @on_calculation = on_calculation
    end

    # used for tes
    def get_total_memory
      @cluster.get_total_memory
    end

    def reap
      return false if @cluster.workers_stopped?

      total = get_total_memory
      @on_calculation&.call(total)

      if @reaper_status_logs
        @cluster.master.log 'PumaWorkerKiller: Status log. ' \
          "total=#{total}mb " \
          "master=#{@cluster.master_memory}md " \
          "worker_count=#{@cluster.workers.count} " \
          "#{@cluster.workers.map { |worker, mem| "worker_#{worker.pid}=#{mem}mb" } * " "}"
      end

      kill(total) if total > @max_ram
    end

    private

    def kill(total_mem)
      @cluster.master.log "PumaWorkerKiller: Out of memory. #{@cluster.workers.count} " \
        "workers and master consuming total: #{total_mem} mb out of max: #{@max_ram} mb. " \
        "Sending TERM to pid #{@cluster.largest_worker.pid} consuming #{@cluster.largest_worker_memory} mb."

      # Fetch the largest_worker so that both `@pre_term` and `term_worker` are called with the same worker
      # Avoids a race condition where:
      #   Worker A consume 100 mb memory
      #   Worker B consume 99 mb memory
      #   pre_term gets called with Worker A
      #   A new request comes in, Worker B takes it, and consumes 101 mb memory
      #   term_largest_worker (previously here) gets called and terms Worker B (thus not passing the about-to-be-terminated worker to `@pre_term`)
      largest_worker = @cluster.largest_worker
      @pre_term&.call(largest_worker)
      @cluster.term_worker(largest_worker)
    end
  end
end
