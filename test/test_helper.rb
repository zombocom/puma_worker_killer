Bundler.require

require 'puma_worker_killer'
require 'test/unit'


require 'securerandom'

# Mock object stand in for Puma::Cluster
class FakeCluster
  def initialize
    @workers = []
  end

  class Worker
    attr_accessor :pid

    def initialize(pid)
      @pid = pid
    end

    def memory_leak
      while true

      end
    end

    # not public interface, used for testing
    def is_term?
      @first_term_sent
    end

    def term
      begin
        if @first_term_sent && (Time.new - @first_term_sent) > 30
          @signal = "KILL"
        else
          @first_term_sent ||= Time.new
        end

        Process.kill "TERM", @pid
      rescue Errno::ESRCH
      end
    end
  end

  def log(msg)
    puts msg
  end

  def do_work
    while true
      SecureRandom.hex(16).to_sym if ENV['CAUSE_MEMORY_LEAK']
      sleep 0.001
    end
  end

  # not a public interface, added to make testing easier
  def workers
    @workers
  end

  def add_worker
    pid = fork { do_work }
    @workers << Worker.new(pid)
  end
end
