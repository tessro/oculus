Given /^a query is cached with results:$/ do |results|
  Oculus::Query.create(:description => "all users", :query => "SELECT * FROM oculus_users", :results => results.raw)
end

When /^I execute "([^"]*)"$/ do |query|
  visit '/'
  find('.CodeMirror :first-child :first-child').native.send_keys(query)
  click_button 'Run'
end

When /^I load the cached query$/ do
  visit '/'
  click_link 'all users'
end

When /^I click delete$/ do
  visit '/'
  find('.delete').click
end

Then /^I should see (\d+) rows of results$/ do |result_count|
  within('#results') do
    all('tr').length.should == result_count.to_i
  end
end

Then /^I should not see any queries$/ do
  within('#history') do
    all('li').length.should == 0
  end
end
