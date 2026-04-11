# Blip

Blip is a small, forking, Rack-compatible HTTP/1.1 server for Ruby. It accepts
connections on a TCP socket, parses requests with `http_parser.rb`, and hands a
standard Rack `env` to your application.

It's intentionally tiny — a learning-oriented server rather than a Puma/Unicorn
replacement.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blip'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blip

## Usage

Blip serves any Rack app. Point it at a `config.ru`:

```ruby
# app/config.ru
class App
  def call(env)
    body = "Hello from pid #{Process.pid}\n"
    [200, { "Content-Type" => "text/plain", "Content-Length" => body.bytesize.to_s }, [body]]
  end
end

run App.new
```

Then start the server:

    $ bin/blip app/config.ru

Environment variables:

- `PORT`    — TCP port to listen on (default `3001`)
- `WORKERS` — number of worker processes to fork (default `2`)

Or embed it directly:

```ruby
require "blip"

app = Blip::Builder.parse_file("app/config.ru")
Blip::Server.new(3001, app).start(4) # 4 workers
```

## How it works

- The parent process opens a listening socket and `fork`s `WORKERS` children.
- Each worker `accept`s connections in a loop and processes them one at a time.
- `Blip::Connection` feeds bytes through `http_parser.rb`, builds a Rack `env`
  (with the request body exposed as `rack.input`), and invokes the app.
- `INT`, `TERM`, and `QUIT` sent to the parent are forwarded to all workers so
  the whole server shuts down cleanly.
- Per-connection parser and I/O errors are rescued so one bad client can't take
  a worker down.

Connections are closed after each response (`Connection: close`); keep-alive is
not implemented.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/navneetpandey/blip.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
