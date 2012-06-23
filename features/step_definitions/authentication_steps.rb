class SimpleAuth
  class << self
    attr_accessor :logged_in
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    case env['PATH_INFO']
    when '/login'
      [200, {'Content-Type' => 'text/html'}, ['hello']]
    else
      if self.class.logged_in
        env['oculus.user.id'] = 1
        env['oculus.user.name'] = 'Paul'
      end

      @app.call(env)
    end
  end
end

Given /^authentication is enabled$/ do
  Capybara.app = Rack::Builder.new do
    use SimpleAuth
    run Oculus::Server
  end

  SimpleAuth.logged_in = false
  Oculus.use_authentication = true
end

When /^I am logged in$/ do
  SimpleAuth.logged_in = true
end

When /^I visit '\/'$/ do
  visit '/'
end

Then /^I should see the editor$/ do
  page.should have_css('#query-form')
end

Then /^I should be redirected to '\/login'$/ do
  current_path.should == '/login'
end

Then /^I should see my name$/ do
  page.should have_content('Paul')
end
