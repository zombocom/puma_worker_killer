load File.expand_path("../fixture_helper.rb", __FILE__)

PumaWorkerKiller.config do |config|
  config.pre_term = lambda { |worker| puts("About to terminate worker: #{worker.inspect}") }
end
PumaWorkerKiller.start

run HelloWorldApp
