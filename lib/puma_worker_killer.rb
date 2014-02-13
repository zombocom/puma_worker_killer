require 'get_process_mem'

module PumaWorkerKiller
  extend self

  attr_accessor :ram, :frequency, :percent_usage
  self.ram           = 512  # mb
  self.frequency     = 10   # seconds
  self.percent_usage = 0.99 # percent of RAM to use

  def config
    yield self
  end

  def reaper(ram = self.ram, percent = self.percent_usage)
    Reaper.new(ram * percent_usage)
  end

  def start(frequency = self.frequency, reaper = self.reaper)
    AutoReap.new(frequency, reaper).start
  end
end

require 'puma_worker_killer/reaper'
require 'puma_worker_killer/auto_reap'
require 'puma_worker_killer/version'