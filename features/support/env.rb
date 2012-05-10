$: << File.expand_path(File.join(__FILE__, '..', '..', '..', 'lib'))

require 'oculus'
require 'oculus/server'
require 'capybara/cucumber'

Capybara.app = Oculus::Server
Capybara.default_wait_time = 10

Oculus.cache_path = 'tmp/test_cache'
Oculus.connection_options = {
  :adapter => 'mysql',
  :host => 'localhost',
  :username => 'root',
  :database => 'oculus_test'
}

Before do
  FileUtils.mkdir_p('tmp/test_cache')
end

After do
  FileUtils.rm_r('tmp/test_cache')
end
