When /^I execute "([^"]*)"$/ do |query|
  @connection ||= Oculus::Connection::Mysql2.new(:database => 'test')
  @results ||= {}
  @results[query] = @connection.execute(query)
  @last_query = query
end

Then /^I should see (\d+) rows of results$/ do |result_count|
  result_count = result_count.to_i
  @results[@last_query].count.should == result_count + 1
end
