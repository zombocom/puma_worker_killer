# frozen_string_literal: true

load File.expand_path('fixture_helper.rb', __dir__)

PumaWorkerKiller.start

run HelloWorldApp
