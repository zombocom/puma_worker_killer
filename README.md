# Puma Worker Killer

[![Build Status](https://travis-ci.org/schneems/puma_worker_killer.png?branch=master)](https://travis-ci.org/schneems/puma_worker_killer)


## What

If you have a memory leak in your code, finding and plugging it can be a herculean effort. Instead what if you just killed your processes when they got to be too large? The Puma Worker Killer does just that. Similar to [Unicorn Worker Killer](https://github.com/kzk/unicorn-worker-killer) but for the Puma web server.

Puma worker killer can only function if you have enabled cluster mode or hybrid mode (threads + worker cluster). If you are only using threads (and not workers) then puma worker killer cannot help keep your memory in control.


## Install

In your Gemfile add:

```ruby
gem 'puma_worker_killer'
```

Then run `$ bundle install`

## Use

Somewhere in your main process run this code:

```ruby
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


## License

MIT


## Feedback

Open up an issue or ping me on twitter [@schneems](http://twitter.com/schneems).