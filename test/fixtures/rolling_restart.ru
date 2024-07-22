# frozen_string_literal: true

load File.expand_path("fixture_helper.rb", __dir__)

PumaWorkerKiller.enable_rolling_restart(1, 0..5.0) # 1 second, short 1-5s splay.

run HelloWorldApp
