$: << File.join(File.dirname(__FILE__), 'lib')

require 'oculus/server'

class SimpleAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    case env['PATH_INFO']
    when '/login'
      [200, {'Content-Type' => 'text/html'}, ['Hello! <a href="/login/do">Login</a>']]
    when '/login/do'
      @logged_in = true
      [302, {'Content-Type' => 'text-html', 'Location' => '/'}, ['Redirecting...']]
    when '/logout'
      @logged_in = false
      [302, {'Content-Type' => 'text-html', 'Location' => '/login'}, ['Redirecting...']] 
    else
      if @logged_in
        env['oculus.user.id'] = 1
        env['oculus.user.name'] = 'Paul'
      end
      @app.call(env)
    end
  end
end

Oculus.use_authentication = true

Oculus.connection_options = {
  adapter: 'mysql',
  database: 'tag_development',
  username: 'root'
}

use SimpleAuth
run Oculus::Server
