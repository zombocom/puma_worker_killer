## Main

## 0.3.1

- Relax puma dependency (#94)

## 0.3.0

- Test on recent ruby versions #84
- Add option to adjust restart randomizer (#78)

## 0.2.0

- Simplify workers memory calculation in PumaMemory‘s `get_total` method #81
- Add rubocop in gemspec and CI, with offenses corrected and unnecessary cops disabled.
- Add `pre_term`-like `rolling_pre_term` config for terminations caused by rolling restart (#86)
- Fix compatibility with ruby version 2.3.X (#87)

## 0.1.1

- Allow PWK to be used with Puma 4 (#72)

## 0.1.0

- Emit extra data via `pre_term` callback before puma worker killer terminates a worker #49.

## 0.0.7

- Logging is configurable #41

## 0.0.6

- Log PID of worker insead of inspecting the worker #33

## 0.0.5

- Support for Puma 3.x

## 0.0.4

- Add ability to do rolling restart

## 0.0.3

- Fix memory metrics in on linux

