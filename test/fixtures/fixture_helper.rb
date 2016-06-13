require 'securerandom'

require 'rack'
require 'rack/server'

require 'puma_worker_killer'

PumaWorkerKiller.config do |config|
  config.ram       = Integer(ENV['PUMA_RAM'])       if ENV['PUMA_RAM']
  config.frequency = Integer(ENV['PUMA_FREQUENCY']) if ENV['PUMA_FREQUENCY']
end

puts "Frequency: #{ PumaWorkerKiller.frequency }" if ENV['PUMA_FREQUENCY']

class HelloWorld
  def response(env)
    [200, {}, ['Hello World']]
  end
end

class HelloWorldApp
  def self.call(env)
    HelloWorld.new.response(env)
  end
end
