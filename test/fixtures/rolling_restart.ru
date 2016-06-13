load File.expand_path("../fixture_helper.rb", __FILE__)

PumaWorkerKiller.enable_rolling_restart(1) # 1 second

run HelloWorldApp
