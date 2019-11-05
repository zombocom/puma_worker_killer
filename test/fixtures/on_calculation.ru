load File.expand_path("../fixture_helper.rb", __FILE__)

PumaWorkerKiller.config do |config|
  config.on_calculation = lambda { |usage| puts("Current memory footprint: #{usage} mb") }
end
PumaWorkerKiller.start

run HelloWorldApp
