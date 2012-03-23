Before do
  @data_store ||= Oculus::Storage::FileStore.new('tmp/data')
  @connection ||= Oculus::Connection::Mysql2.new(:database => 'test')
end

Given /^a query is cached with results:$/ do |results|
  Oculus::Query.data_store ||= @data_store
  @last_query = Oculus::Query.create(:description => "all users", :query => "SELECT * FROM oculus_users", :results => results.raw)
end

When /^I execute "([^"]*)"$/ do |query|
  @results = @connection.execute(query)
end

When /^I load the cached query$/ do
  @results = @data_store.load_query(@last_query.id).results
end

Then /^I should see (\d+) rows of results$/ do |result_count|
  result_count = result_count.to_i
  @results.count.should == result_count + 1
end
