# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puma_worker_killer/version'

Gem::Specification.new do |gem|
  gem.name          = 'puma_worker_killer'
  gem.version       = PumaWorkerKiller::VERSION
  gem.authors       = ['Richard Schneeman']
  gem.email         = ['richard.schneeman+rubygems@gmail.com']
  gem.description   = ' Kills pumas, the code kind '
  gem.summary       = ' If you have a memory leak in your web code puma_worker_killer can keep it in check. '
  gem.homepage      = 'https://github.com/schneems/puma_worker_killer'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'get_process_mem',   '~>  0.2'
  gem.add_dependency 'puma',              '>= 2.7'
  gem.add_development_dependency 'rack', '~> 2.0'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'test-unit', '>= 0'
  gem.add_development_dependency 'wait_for_it', '~> 0.1'
end
