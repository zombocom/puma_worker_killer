module PumaWorkerKiller
  class PumaMemory
    def initialize(master = nil)
      @master  = master || get_master
    end

    def master
      @master
    end

    def size
      workers.size
    end

    def term_worker(worker)
      worker.term
    end

    def term_largest_worker
      largest_worker.term
    #   Process.wait(largest_worker.pid)
    # rescue Errno::ECHILD
    end

    def workers_stopped?
      !running?
    end

    def running?
      @master && workers.any?
    end

    def smallest_worker
      smallest, _ = workers.to_a.first
      smallest
    end

    def smallest_worker_memory
      _, smallest_mem = workers.to_a.first
      smallest_mem
    end

    def largest_worker
      largest_worker, _ = workers.to_a.last
      largest_worker
    end

    def largest_worker_memory
      _, largest_memory_used = workers.to_a.last
      largest_memory_used
    end

    # Will refresh @workers
    def get_total(workers = set_workers)
      master_memory = GetProcessMem.new(Process.pid).mb
      worker_memory = workers.map {|_, mem| mem }.inject(&:+) || 0
      worker_memory + master_memory
    end
    alias :get_total_memory :get_total

    def workers
      @workers || set_workers
    end

    private

    def get_master
      ObjectSpace.each_object(Puma::Cluster).map { |obj| obj }.first if defined?(Puma::Cluster)
    end

    # Returns sorted hash, keys are worker objects, values are memory used per worker
    # sorted by memory ascending (smallest first, largest last)
    def set_workers
      workers = {}
      @master.instance_variable_get("@workers").each do |worker|
        workers[worker] = GetProcessMem.new(worker.pid).mb
      end
      if workers.any?
        @workers = Hash[ workers.sort_by {|_, mem| mem } ]
      else
        {}
      end
    end
  end
end
