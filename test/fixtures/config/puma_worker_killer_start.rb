load File.expand_path("../../fixture_helper.rb", __FILE__)

before_fork do
  require 'puma_worker_killer'
  PumaWorkerKiller.start
end
