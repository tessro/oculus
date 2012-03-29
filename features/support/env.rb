$: << File.expand_path(File.join(__FILE__, '..', '..', '..', 'lib'))

require 'oculus'
require 'oculus/server'
require 'capybara/cucumber'

Capybara.app = Oculus::Server

Oculus.cache_path = 'tmp/test_cache'

Before do
  Dir.mkdir('tmp/test_cache')
end

After do
  FileUtils.rm_r('tmp/test_cache')
end
