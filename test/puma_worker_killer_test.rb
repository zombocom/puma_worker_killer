require 'test_helper'

class PumaWorkerKillerTest < Test::Unit::TestCase

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
    before = ENV['CAUSE_MEMORY_LEAK']
    ram     = 50 #mb
    cluster = FakeCluster.new
    reaper  = PumaWorkerKiller::Reaper.new(ram, cluster)
    worker_count = 20
    worker_count.times { cluster.add_worker }
    assert_equal worker_count, cluster.workers.count
    refute cluster.workers.detect {|w| w.is_term? }

    reaper.reap
    assert_equal 0, cluster.workers.select {|w| w.is_term? }.count
    ENV['CAUSE_MEMORY_LEAK'] = "true"
    sleep 2

    reaper.reap
    assert_equal 1, cluster.workers.select {|w| w.is_term? }.count
  ensure
    ENV['CAUSE_MEMORY_LEAK'] = before
    cluster.workers.map(&:term)
  end

end
