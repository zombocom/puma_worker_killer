# frozen_string_literal: true

load File.expand_path('fixture_helper.rb', __dir__)

PumaWorkerKiller.config do |config|
  config.on_calculation = ->(usage) { puts("Current memory footprint: #{usage} mb") }
end
PumaWorkerKiller.start

run HelloWorldApp
