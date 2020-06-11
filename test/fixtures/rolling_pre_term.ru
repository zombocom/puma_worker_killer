load File.expand_path("../fixture_helper.rb", __FILE__)

PumaWorkerKiller.config do |config|
  config.rolling_pre_term = lambda { |worker| puts("About to terminate (rolling) worker: #{worker.pid}") }
end
PumaWorkerKiller.enable_rolling_restart(1) # 1 second

run HelloWorldApp
