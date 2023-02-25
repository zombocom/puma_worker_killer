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

      if total > @max_ram
        exceeded_memory = 0
        to_kill = []
        @cluster.workers.to_a.reverse_each do |item|
          exceeded_memory += item[1]
          to_kill << item
          break if total - exceeded_memory < @max_ram
        end

        log_entry = "PumaWorkerKiller: Out of memory. #{@cluster.workers.count} workers consuming total: #{total} mb out of max: #{@max_ram} mb. " \
          "Releasing #{exceeded_memory} mb from #{to_kill.length} workers."
        to_kill.each do |item|
          worker = item[0]
          mem = item[1]
          log_entry += "\r\n\tSending TERM to pid #{worker.pid} consuming #{mem} mb."
          @pre_term&.call(worker)
          @cluster.term_worker(worker)
        end
        @cluster.master.log(log_entry)
      elsif @reaper_status_logs
        @cluster.master.log("PumaWorkerKiller: Consuming #{total} mb with master and #{@cluster.workers.count} workers.")
      end
    end
  end
end
