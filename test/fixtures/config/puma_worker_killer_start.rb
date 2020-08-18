# frozen_string_literal: true

load File.expand_path('../fixture_helper.rb', __dir__)

before_fork do
  require 'puma_worker_killer'
  PumaWorkerKiller.start
end
