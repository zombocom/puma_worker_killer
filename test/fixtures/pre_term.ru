# frozen_string_literal: true

load File.expand_path('fixture_helper.rb', __dir__)

PumaWorkerKiller.config do |config|
  config.pre_term = ->(worker) { puts("About to terminate worker: #{worker.inspect}") }
end
PumaWorkerKiller.start

run HelloWorldApp
