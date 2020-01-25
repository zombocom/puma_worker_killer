module PumaWorkerKiller
  class RequestsCountReaper
    def initialize(requests_count, master = nil)
      @requests_count = requests_count
      @cluster = PumaWorkerKiller::PumaRequestsCount.new(master)
    end

    attr_reader :requests_count

    def reap(wait_between_worker_kill = 60) # seconds
      @cluster.set_workers
      return false unless @cluster.running?

      @cluster.workers.each do |worker, w_requests_count|
        @cluster.master.log "PumaWorkerKiller: Requests Count Restart. #{@cluster.workers.count} workers #{worker.pid}. #{w_requests_count}"
        next unless w_requests_count > requests_count
        @cluster.master.log "PumaWorkerKiller: Requests Count Restart. #{@cluster.workers.count} workers Sending TERM to pid #{worker.pid}. because requests count = #{w_requests_count}"
        worker.term
        sleep wait_between_worker_kill
      end
    end
  end
end
