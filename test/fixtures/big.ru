require_relative 'fixture_helper.rb'
PumaWorkerKiller.start

@memory = []
10_000.times.each do
  @memory << SecureRandom.hex
end

run HelloWorldApp
