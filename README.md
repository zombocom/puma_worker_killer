# Puma Worker Killer

[![Build Status](https://travis-ci.org/schneems/puma_worker_killer.png?branch=master)](https://travis-ci.org/schneems/puma_worker_killer)


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

Somewhere in your main process run this code:

```ruby
# config/initializers/puma_worker_killer.rb
PumaWorkerKiller.start
```

That's it. Now on a regular basis the size of all Puma and all of it's forked processes will be evaluated and if they're over the RAM threshold will be killed. Don't worry Puma will notice a process is missing a spawn a fresh copy with a much smaller RAM footprint ASAP.

## Configure

Before calling `start` you can configure `PumaWorkerKiller`. You can do so using a configure block or calling methods directly:

```ruby
PumaWorkerKiller.config do |config|
  config.ram           = 1024 # mb
  config.frequency     = 5    # seconds
  config.percent_usage = 0.98
  config.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds
end
PumaWorkerKiller.start
```

## Attention
If you start puma as a daemon, to add puma worker killer config into puma config file, rather than into initializers:    
Sample like this: (in puma.rb file)
```ruby
before_fork do
  PumaWorkerKiller.config do |config|
    config.ram           = 1024 # mb
    config.frequency     = 5    # seconds
    config.percent_usage = 0.98
    config.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds
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
PumaWorkerKiller.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds
```

By default PumaWorkerKiller will perform a rolling restart of all your worker processes every 12 hours. To disable, set to `false`.

## Only turn on Rolling Restarts

If you're running on a platform like [Heroku where it is difficult to measure RAM from inside of a container accurately](https://github.com/schneems/get_process_mem/issues/7), you may want to disable the "worker killer" functionality and only use the rolling restart. You can do that by running:

```ruby
PumaWorkerKiller.enable_rolling_restart # Default is every 6 hours
```

or you can pass in the restart frequency

```ruby
PumaWorkerKiller.enable_rolling_restart(12 * 3600) # 12 hours in seconds
```

Make sure if you do this to not accidentally call `PumaWorkerKiller.start` as well.

## License

MIT


## Feedback

Open up an issue or ping me on twitter [@schneems](http://twitter.com/schneems).
