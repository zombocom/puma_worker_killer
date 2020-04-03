# frozen_string_literal: true

load File.expand_path('fixture_helper.rb', __dir__)

PumaWorkerKiller.start

@memory = []
10_000.times.each do
  @memory << SecureRandom.hex
end

run HelloWorldApp
