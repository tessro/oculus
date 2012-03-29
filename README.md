# Oculus

![The Oculus of the Pantheon](http://upload.wikimedia.org/wikipedia/commons/1/17/Oculus_of_the_Pantheon.jpg)

Oculus is a web-based logging SQL client.  It keeps a history of your queries
and the results they returned, so your research is always at hand, easy to share
and easy to repeat or reproduce in the future.

**Oculus is alpha software. Interface and implementation may change suddenly!**

## Installation

    $ gem install oculus

## Usage

Oculus is a Sinatra app. Run it from the command line, or mount `Oculus::Server`
as middleware in your Rack application.

For details on command line options, run:

    oculus --help

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
