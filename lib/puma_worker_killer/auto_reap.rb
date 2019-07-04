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
          sleep @timeout
          @reaper.reap
        end
      end
    end
  end
end
