require 'test_helper'

class PumaWorkerKillerTest < Test::Unit::TestCase

  def test_starts
    port     = 0 # http://stackoverflow.com/questions/200484/how-do-you-find-a-free-tcp-server-port-using-ruby
    command  = "bundle exec puma #{ fixture_path.join("default.ru") } -t 1:1 -w 2 --preload --debug -p #{ port }"
    options  = { wait_for: "booted", timeout: 5, env: { "PUMA_FREQUENCY" => 1 } }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "PumaWorkerKiller")
    end
  end

  def test_without_preload
    port     = 0 # http://stackoverflow.com/questions/200484/how-do-you-find-a-free-tcp-server-port-using-ruby
    command  = "bundle exec puma #{ fixture_path.join("default.ru") } -t 1:1 -w 2 --debug -p #{ port } -C #{ fixture_path.join("config/puma_worker_killer_start.rb") }"
    options  = { wait_for: "booted", timeout: 10, env: { "PUMA_FREQUENCY" => 1 } }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "PumaWorkerKiller")
    end
  end

  def test_kills_large_app
    file     = fixture_path.join("big.ru")
    port     = 0
    command  = "bundle exec puma #{ file } -t 1:1 -w 2 --preload --debug -p #{ port }"
    options  = { wait_for: "booted", timeout: 5, env: { "PUMA_FREQUENCY" => 1, 'PUMA_RAM' => 1} }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "Out of memory")
    end
  end

  def test_pre_term
    file     = fixture_path.join("pre_term.ru")
    port     = 0
    command  = "bundle exec puma #{ file } -t 1:1 -w 2 --preload --debug -p #{ port }"
    options  = { wait_for: "booted", timeout: 5, env: { "PUMA_FREQUENCY" => 1, 'PUMA_RAM' => 1} }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "Out of memory")
      assert_contains(spawn, "About to terminate worker:") # defined in pre_term.ru
    end
  end

  def test_on_calculation
    file     = fixture_path.join("on_calculation.ru")
    port     = 0
    command  = "bundle exec puma #{ file } -t 1:1 -w 2 --preload --debug -p #{ port }"
    options  = { wait_for: "booted", timeout: 5, env: { "PUMA_FREQUENCY" => 1, 'PUMA_RAM' => 1} }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "Out of memory")
      assert_contains(spawn, "Current memory footprint:") # defined in on_calculate.ru
    end
  end

  def assert_contains(spawn, string)
    assert spawn.wait(string), "Expected logs to contain '#{string}' but it did not, contents: #{ spawn.log.read }"
  end

  def test_rolling_restart

    file     = fixture_path.join("rolling_restart.ru")
    port     = 0
    command  = "bundle exec puma #{ file } -t 1:1 -w 2 --preload --debug -p #{ port }"
    puts command.inspect
    options  = { wait_for: "booted", timeout: 15, env: { } }

    WaitForIt.new(command, options) do |spawn|
      assert_contains(spawn, "Rolling Restart")
    end
  end
end
