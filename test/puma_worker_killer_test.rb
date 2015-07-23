require 'test_helper'

class PumaWorkerKillerTest < Test::Unit::TestCase

  def test_starts
    app_path = fixture_path.join("app.ru")
    port     = 0 # http://stackoverflow.com/questions/200484/how-do-you-find-a-free-tcp-server-port-using-ruby
    puma_log = Pathname.new "#{ SecureRandom.hex }-puma.log"
    pid  = Process.spawn("PUMA_FREQUENCY=1 bundle exec puma #{ app_path } -t 1:1 -w 5 --preload --debug -p #{ port } > #{puma_log}")
    sleep 5
    assert_match "PumaWorkerKiller:", puma_log.read
  ensure
    puma_log.delete
    Process.kill('TERM', pid) if pid
  end

  def test_worker_reaped
    ram      = 1 #mb
    cluster = FakeCluster.new
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


  def test_rolling_restart
    ram     = rand(75..100) #mb
    cluster = FakeCluster.new
    cluster.add_worker

    worker = cluster.workers.first
    reaper = PumaWorkerKiller::RollingRestart.new(cluster)
    reaper.reap(1)

    assert_equal 1, cluster.workers.select {|w| w.is_term? }.count
  ensure
    cluster.workers.map(&:term)
  end
end

