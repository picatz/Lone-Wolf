# Lone Wolf
> Background worker process API

## Installation

    $ gem install lone_wolf

## Usage

```ruby
# a simple job
work = Proc.new { |var| print "Hello #{var}!" }

# start a background process to do the job in a loop forever
worker = LoneWolf::Worker.new(job: work, loop: true, start: true)

# send work to the worker
["Kent", "Chuck", "Sam", "Brian"].each do |name|
  worker.input.write name
end

# kill the worker 
worker.kill!
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
