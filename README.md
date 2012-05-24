# Oculus

![The Oculus of the Pantheon](http://upload.wikimedia.org/wikipedia/commons/1/17/Oculus_of_the_Pantheon.jpg)

[![Build Status](https://secure.travis-ci.org/paulrosania/oculus.png?branch=master)](http://travis-ci.org/paulrosania/oculus)
[![Dependency Status](https://gemnasium.com/paulrosania/oculus.png)](https://gemnasium.com/paulrosania/oculus)

Oculus is a web-based logging SQL client.  It keeps a history of your queries
and the results they returned, so your research is always at hand, easy to share
and easy to repeat or reproduce in the future.

**Oculus will not prevent you from doing stupid things! I recommend using a
readonly MySQL account.**

## Installation

    $ gem install oculus

## Usage

Oculus is a Sinatra app. Run it from the command line, or mount `Oculus::Server`
as middleware in your Rack application.

For details on command line options, run:

    oculus --help

## Contributing

1. Fork it
2. Run `rake db:test:populate`
3. Make your changes
4. Run tests (`rake`)
5. Send me a pull request

If you're making a big change, please open an Issue first, so we can discuss.
