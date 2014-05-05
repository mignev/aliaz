# Aliaz

# Don't waste your time here. This is just an experiment.

The idea behind this script is to extend every shell command with custom arguments. The inspiration came from the idea of Git aliases.

### Usage

Without aliaser

    app create -t python-2.7 -a myapp
    app delete --confirm myapp

With aliaser

    app create.py myapp
    app delete! myapp

### Config a.k.a config.yml

```yaml
app:
  delete!: delete --confirm
  create.py: create -t python-2.7 -a

python:
  server: -m SimpleHTTPServer
```

## Installation

Add this line to your application's Gemfile:

    gem 'aliaz'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aliaz
    $ echo 'source /dev/stdin <<<  $(aliaz aliases --bash)' >> ~/.bashrc

## Contributing

1. Fork it ( http://github.com/mignev/aliaz/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
