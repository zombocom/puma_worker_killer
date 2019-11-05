# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puma_worker_killer/version'

Gem::Specification.new do |gem|
  gem.name          = "puma_worker_killer"
  gem.version       = PumaWorkerKiller::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{ Kills pumas, the code kind }
  gem.summary       = %q{ If you have a memory leak in your web code puma_worker_killer can keep it in check. }
  gem.homepage      = "https://github.com/schneems/puma_worker_killer"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "puma",              ">= 2.7", "< 5"
  gem.add_dependency "get_process_mem",   "~>  0.2"
  gem.add_development_dependency "rack", "~> 1.6"
  gem.add_development_dependency "wait_for_it", "~> 0.1"
  gem.add_development_dependency "rake",  "~> 10.1"
  gem.add_development_dependency "test-unit",  ">= 0"

end
