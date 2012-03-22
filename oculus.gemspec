# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oculus/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Rosania"]
  gem.email         = ["paul.rosania@gmail.com"]
  gem.description   = %q{Oculus is a web-based logging SQL client.  It keeps a history of your queries and the results they returned, so your research is always at hand, easy to share and easy to repeat or reproduce in the future.}
  gem.summary       = %q{Oculus is a web-based logging SQL client.}
  gem.homepage      = "https://github.com/paulrosania/oculus"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "oculus"
  gem.require_paths = ["lib"]
  gem.version       = Oculus::VERSION

  gem.add_runtime_dependency "sinatra", [">= 1.3.0"]
  gem.add_runtime_dependency "mysql2",  [">= 0.3.11"]
  gem.add_runtime_dependency "vegas",   [">= 0.1.4"]

  gem.add_development_dependency "cucumber", [">= 1"]
  gem.add_development_dependency "rspec",    [">= 2"]
end
