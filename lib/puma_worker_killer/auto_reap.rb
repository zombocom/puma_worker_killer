module PumaWorkerKiller
  class AutoReap
    def initialize(timeout, reaper = Reaper.new)
      @timeout = timeout # seconds
      @reaper  = reaper
      @running = false
    end

    def start
      @running = true

      Thread.new do
        while @running
          @reaper.reap
          sleep @timeout
        end
      end
    end

  end
end
