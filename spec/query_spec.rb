require 'oculus'

describe Oculus::Query do
  before do
    Oculus.data_store = stub
  end

  it "stores the query itself" do
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.query.should == 'SELECT * FROM users'
  end

  it "has a description" do
    query = Oculus::Query.new(:description => 'foo')
    query.description.should == 'foo'
  end

  it "stores new queries in the data store" do
    Oculus.data_store.should_receive(:save_query)
    query = Oculus::Query.create(:results => [['id', 'name'], [1, 'Paul']])
  end

  it "retrieves cached queries from the data store" do
    Oculus.data_store.should_receive(:load_query).with(1)
    Oculus::Query.find(1)
  end
end
