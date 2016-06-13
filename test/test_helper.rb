Bundler.require

require 'puma_worker_killer'
require 'test/unit'
require 'wait_for_it'

def fixture_path
  Pathname.new(File.expand_path("../fixtures", __FILE__))
end
