# Puma Worker Killer

[![Build Status](https://travis-ci.org/schneems/puma_worker_killer.png?branch=master)](https://travis-ci.org/schneems/puma_worker_killer)
[![Help Contribute to Open Source](https://www.codetriage.com/schneems/puma_worker_killer/badges/users.svg)](https://www.codetriage.com/schneems/puma_worker_killer)


## What

If you have a memory leak in your code, finding and plugging it can be a herculean effort. Instead what if you just killed your processes when they got to be too large? The Puma Worker Killer does just that. Similar to [Unicorn Worker Killer](https://github.com/kzk/unicorn-worker-killer) but for the Puma web server.

Puma worker killer can only function if you have enabled cluster mode or hybrid mode (threads + worker cluster). If you are only using threads (and not workers) then puma worker killer cannot help keep your memory in control.

BTW restarting your processes to control memory is like putting a bandaid on a gunshot wound, try figuring out the reason you're seeing so much memory bloat [derailed benchmarks](https://github.com/schneems/derailed_benchmarks) can help.


## Install

In your Gemfile add:

```ruby
gem 'puma_worker_killer'
```

Then run `$ bundle install`

<!--
## Use

> If you like `puma_worker_killer` consider using [puma_auto_tune instead](https://github.com/schneems/puma_auto_tune). It handles memory leaks and tunes your workers too!

-->

## Turn on Rolling Restarts

A rolling restart will kill each of your workers on a rolling basis. You set the frequency which it conducts the restart. This is a simple way to keep memory down as Ruby web programs generally increase memory usage over time. If you're using Heroku [it is difficult to measure RAM from inside of a container accurately](https://github.com/schneems/get_process_mem/issues/7), so it is recommended to use this feature or use a [log-drain-based worker killer](https://github.com/arches/whacamole). You can enable roling restarts by running:

```ruby
# config/puma.rb

before_fork do
  require 'puma_worker_killer'

  PumaWorkerKiller.enable_rolling_restart # Default is every 6 hours
end

```

or you can pass in the restart frequency:

```ruby
PumaWorkerKiller.enable_rolling_restart(12 * 3600) # 12 hours in seconds
```

Make sure if you do this to not accidentally call `PumaWorkerKiller.start` as well.

## Enable Worker Killing

If you're not running on a containerized platform you can try to detect the amount of memory you're using and only kill Puma workers when you're over that limit. It may allow you to go for longer periods of time without killing a worker however it is more error prone than rolling restarts. To enable measurement based worker killing put this in your `config/puma.rb`:

```ruby
# config/puma.rb

before_fork do
  require 'puma_worker_killer'

  PumaWorkerKiller.start
end
```

That's it. Now on a regular basis the size of all Puma and all of it's forked processes will be evaluated and if they're over the RAM threshold will be killed. Don't worry Puma will notice a process is missing and spawn a fresh copy with a much smaller RAM footprint ASAP.

## Troubleshooting

When you boot your program locally you should see debug output:

```
[77773] Puma starting in cluster mode...
[77773] * Version 3.1.0 (ruby 2.3.1-p112), codename: El Niño Winter Wonderland
[77773] * Min threads: 0, max threads: 16
[77773] * Environment: development
[77773] * Process workers: 2
[77773] * Phased restart available
[77773] * Listening on tcp://0.0.0.0:9292
[77773] Use Ctrl-C to stop
[77773] PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.
```

If you don't see any `PumaWorkerKiller` output, make sure that you are running with multiple workers. PWK only functions if you have workers enabled, you should see something like this when Puma boots:

```
[77773] * Process workers: 2
```

If you've configured PWK's frequency try reducing it to a very low value


## Configure

Before calling `start` you can configure `PumaWorkerKiller`. You can do so using a configure block or calling methods directly:

```ruby
PumaWorkerKiller.config do |config|
  config.ram           = 1024 # mb
  config.frequency     = 5    # seconds
  config.percent_usage = 0.98
  config.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds, or 12.hours if using Rails
  config.reaper_status_logs = true # setting this to false will not log lines like:
  # PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.

  config.pre_term = -> (worker) { puts "Worker #{worker.inspect} being killed" }
end
PumaWorkerKiller.start
```

### pre_term

`config.pre_term` will be called just prior to worker termination with the worker that is about to be terminated. This may be useful to use in keeping track of metrics, time of day workers are restarted, etc.

By default Puma Worker Killer will emit a log when a worker is being killed

```
PumaWorkerKiller: Out of memory. 5 workers consuming total: 500 mb out of max: 450 mb. Sending TERM to pid 23 consuming 53 mb.
```

or

```
PumaWorkerKiller: Rolling Restart. 5 workers consuming total: 650mb mb. Sending TERM to pid 34.
```

However you may want to collect more data, such as sending an event to an error collection service like rollbar or airbrake. The `pre_term` lambda gets called before any worker is killed by PWK for any reason.

### on_calculation

`config.on_calculation` will be called every time Puma Worker Killer calculates memory usage (`config.frequency`). This may be useful for monitoring your total puma application memory usage, which can be contrasted with other application monitoring solutions.

This callback lambda is given a single value for the amount of memory used.

## Attention

If you start puma as a daemon, to add puma worker killer config into puma config file, rather than into initializers:
Sample like this: (in `config/puma.rb` file):

```ruby
before_fork do
  PumaWorkerKiller.config do |config|
    config.ram           = 1024 # mb
    config.frequency     = 5    # seconds
    config.percent_usage = 0.98
    config.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds, or 12.hours if using Rails
  end
  PumaWorkerKiller.start
end
```

It is important that you tell your code how much RAM is available on your system. The default is 512 mb (the same size as a Heroku 1x dyno). You can change this value like this:

```ruby
PumaWorkerKiller.ram = 1024 # mb
```

By default it is assumed that you do not want to hit 100% utilization, that is if your code is actually using 512 mb out of 512 mb it would be bad (this is dangerously close to swapping memory and slowing down your programs). So by default processes will be killed when they are at 99 % utilization of the value specified in `PumaWorkerKiller.ram`. You can change that value to 98 % like this:

```ruby
PumaWorkerKiller.percent_usage = 0.98
```

You may want to tune the worker killer to run more or less often. You can adjust frequency:

```ruby
PumaWorkerKiller.frequency = 20 # seconds
```

You may want to periodically restart all of your workers rather than simply killing your largest. To do that set:

```ruby
PumaWorkerKiller.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds, or 12.hours if using Rails
```

By default PumaWorkerKiller will perform a rolling restart of all your worker processes every 6 hours. To disable, set to `false`.

You may want to hide the following log lines: `PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.`. To do that set:

```ruby
PumaWorkerKiller.reaper_status_logs = false
```

Note: It is `true` by default.

## License

MIT

## Feedback

Open up an issue or ping me on twitter [@schneems](http://twitter.com/schneems).
