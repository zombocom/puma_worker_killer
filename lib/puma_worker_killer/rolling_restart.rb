module PumaWorkerKiller
  class RollingRestart
    def initialize(master = nil)
      @cluster = PumaWorkerKiller::PumaMemory.new(master)
    end

    # used for tes
    def get_total_memory
      @cluster.get_total_memory
    end

    def reap(wait_till_next = 60)
      return false unless @cluster.running?
      @cluster.workers.sort.shuffle.each do |worker, ram|
        @cluster.master.log "PumaWorkerKiller: Rolling Restart. #{@cluster.workers.count} workers consuming total: #{ get_total_memory } mb out of max: #{@max_ram} mb. Sending TERM to #{worker.inspect}"
        worker.term
        sleep wait_till_next
      end
    end
  end
end
