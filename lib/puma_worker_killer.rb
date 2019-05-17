require 'get_process_mem'

module PumaWorkerKiller
  extend self

  attr_accessor :ram, :frequency, :percent_usage, :rolling_restart_frequency, :reaper_status_logs, :pre_term, :on_calculation
  self.ram           = 512  # mb
  self.frequency     = 10   # seconds
  self.percent_usage = 0.99 # percent of RAM to use
  self.rolling_restart_frequency = 6 * 3600 # 6 hours in seconds
  self.reaper_status_logs = true
  self.pre_term = nil
  self.on_calculation = nil

  def config
    yield self
  end

  def reaper(ram = self.ram, percent = self.percent_usage, reaper_status_logs = self.reaper_status_logs, pre_term = self.pre_term, on_calculation = self.on_calculation)
    Reaper.new(ram * percent_usage, nil, reaper_status_logs, pre_term, on_calculation)
  end

  def start(frequency = self.frequency, reaper = self.reaper)
    AutoReap.new(frequency, reaper).start
    enable_rolling_restart(rolling_restart_frequency) if rolling_restart_frequency
  end

  def enable_rolling_restart(frequency = self.rolling_restart_frequency)
    frequency = frequency + rand(0..10.0) # so all workers don't restart at the exact same time across multiple machines
    AutoReap.new(frequency, RollingRestart.new).start
  end
end

require 'puma_worker_killer/puma_memory'
require 'puma_worker_killer/reaper'
require 'puma_worker_killer/rolling_restart'
require 'puma_worker_killer/auto_reap'
require 'puma_worker_killer/version'
