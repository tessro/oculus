Given /^a query is cached with results:$/ do |results|
  Oculus::Query.create(:description => "all users", :query => "SELECT * FROM oculus_users", :results => results.raw)
end

When /^I execute "([^"]*)"$/ do |query|
  visit '/'
  fill_in('query', :with => query)
  click_button 'Run'
end

When /^I load the cached query$/ do
  visit '/'
  click_link 'all users'
end

Then /^I should see (\d+) rows of results$/ do |result_count|
  within('#results') do
    all('tr').length.should == result_count.to_i
  end
end
