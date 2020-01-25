module PumaWorkerKiller
  class PumaRequestsCount
    def initialize(master = nil)
      @master  = master || get_master
      @workers = nil
    end

    attr_reader :master

    def running?
      @master && workers.any?
    end

    def workers
      @workers || set_workers
    end

    # Returns sorted hash, keys are worker objects, values are memory used per worker
    # sorted by memory ascending (smallest first, largest last)
    def set_workers
      @workers = {}
      @master.instance_variable_get("@workers").each do |worker|
        @workers[worker] = worker.last_status[:requests_count] || 0
      end
      @workers
    end

    private

    def get_master
      ObjectSpace.each_object(Puma::Cluster).map { |obj| obj }.first if defined?(Puma::Cluster)
    end
  end
end
