require_relative 'fixture_helper.rb'
PumaWorkerKiller.enable_rolling_restart(1) # 1 second

run HelloWorldApp
