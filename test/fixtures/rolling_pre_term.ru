# frozen_string_literal: true

load File.expand_path("fixture_helper.rb", __dir__)

PumaWorkerKiller.config do |config|
  config.rolling_pre_term = ->(worker) { puts("About to terminate (rolling) worker: #{worker.pid}") }
end
PumaWorkerKiller.enable_rolling_restart(1, 0..5.0) # 1 second, short 1-5s splay.

run HelloWorldApp
