require 'test_helper'

class PumaWorkerKillerTest < Test::Unit::TestCase

  def test_starts
    port     = 0 # http://stackoverflow.com/questions/200484/how-do-you-find-a-free-tcp-server-port-using-ruby
    command  = "bundle exec puma #{ fixture_path.join("default.ru") } -t 1:1 -w 5 --preload --debug -p #{ port }"
    options  = { wait_for: "PumaWorkerKiller:", timeout: 5, env: { "PUMA_FREQUENCY" => 1 } }

    WaitForIt.new(command, options) do |spawn|
      #
    end
  end

  def test_kills_large_app
    file     = fixture_path.join("big.ru")
    port     = 0
    command  = "bundle exec puma #{ file } -t 1:1 -w 5 --preload --debug -p #{ port }"
    options  = { wait_for: "PumaWorkerKiller:", timeout: 5, env: { "PUMA_FREQUENCY" => 1, 'PUMA_RAM' => 1} }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "Out of memory")
    end
  end

  def test_worker_reaped
    ram      = 1 #mb
    cluster  = FakeCluster.new
    reaper   = PumaWorkerKiller::Reaper.new(ram, cluster)
    worker_count = 10
    worker_count.times { cluster.add_worker }

    assert_equal worker_count, cluster.workers.count
    refute cluster.workers.detect {|w| w.is_term? }

    reaper.reap
    assert_equal 1, cluster.workers.select {|w| w.is_term? }.count

    reaper.reap
    assert_equal 2, cluster.workers.select {|w| w.is_term? }.count

    reaper.reap
    assert_equal 3, cluster.workers.select {|w| w.is_term? }.count
  ensure
    cluster.workers.map(&:term)
  end

  def test_kills_memory_leak
    ram     = rand(75..100) #mb
    cluster = FakeCluster.new
    reaper  = PumaWorkerKiller::Reaper.new(ram, cluster)
    while reaper.get_total_memory < (ram * 0.80)
      cluster.add_worker
      sleep 0.01
    end

    reaper.reap
    assert_equal 0, cluster.workers.select {|w| w.is_term? }.count

    until reaper.get_total_memory > ram
      cluster.add_worker
      sleep 0.01
    end

    reaper.reap
    assert_equal 1, cluster.workers.select {|w| w.is_term? }.count
  ensure
    cluster.workers.map(&:term)
  end

  def assert_contains(spawn, string)
    assert spawn.wait(string), "Expected logs to contain '#{string}' but it did not, contents: #{ spawn.log.read }"
  end

  def test_rolling_restart

    file     = fixture_path.join("rolling_restart.ru")
    port     = 0
    command  = "bundle exec puma #{ file } -t 1:1 -w 5 --preload --debug -p #{ port }"
    puts command.inspect
    options  = { wait_for: "booted", timeout: 10, env: { } }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "Rolling Restart")
    end
  end
end

