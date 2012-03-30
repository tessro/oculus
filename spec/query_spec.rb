require 'oculus'

describe Oculus::Query do
  before do
    Oculus.data_store = stub
  end

  it "stores the query itself" do
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.query.should == 'SELECT * FROM users'
  end

  it "has a date" do
    query = Oculus::Query.new
    query.date.should be nil
  end

  it "updates date on save" do
    Oculus.data_store.stub(:save_query)
    Time.stub(:now).and_return(now = stub)
    query = Oculus::Query.create(:results => [['id', 'name'], [1, 'Paul']])
    query.date.should == now
  end

  it "has a description" do
    query = Oculus::Query.new(:description => 'foo')
    query.description.should == 'foo'
  end

  it "has an author" do
    query = Oculus::Query.new(:author => 'Paul')
    query.author.should == 'Paul'
  end

  it "stores new queries in the data store on creation" do
    Oculus.data_store.should_receive(:save_query)
    query = Oculus::Query.create(:results => [['id', 'name'], [1, 'Paul']])
  end

  it "stores new queries in the data store on save" do
    Oculus.data_store.should_receive(:save_query)
    query = Oculus::Query.new(:results => [['id', 'name'], [1, 'Paul']])
    query.save
  end

  it "retrieves cached queries from the data store" do
    Oculus.data_store.should_receive(:load_query).with(1)
    Oculus::Query.find(1)
  end

  it "is not ready when no results are present" do
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.should_not be_ready
  end

  it "is ready when results are present" do
    query = Oculus::Query.new(:results => [['id', 'name'], [1, 'Paul']])
    query.should be_ready
  end
end
