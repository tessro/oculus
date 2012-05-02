require 'oculus'

describe Oculus::Query do
  before do
    Oculus.data_store = stub
  end

  it "runs the query against the supplied connection" do
    connection = stub
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    connection.should_receive(:execute).with('SELECT * FROM users')
    query.execute(connection)
  end

  it "stores the results of running the query" do
    connection = stub(:execute => [['id', 'name'], [1, 'Paul']])
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.execute(connection)
    query.results.should == [['id', 'name'], [1, 'Paul']]
  end

  it "stores errors when queries fail" do
    connection = stub
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    connection.stub(:execute).and_raise(Oculus::Connection::Error.new('You have an error in your SQL syntax'))
    query.execute(connection)
    query.error.should == 'You have an error in your SQL syntax'
  end

  it "stores the query itself" do
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.query.should == 'SELECT * FROM users'
  end

  it "stores the querying connection's thread ID" do
    query = Oculus::Query.new(:thread_id => 42)
    query.thread_id.should == 42
  end

  it "has a start time" do
    query = Oculus::Query.new
    query.started_at.should be nil
  end

  it "has a finish time" do
    query = Oculus::Query.new
    query.finished_at.should be nil
  end

  it "updates start time when executing" do
    Time.stub(:now).and_return(now = stub)
    connection = stub(:execute => [['id', 'name'], [1, 'Paul']])
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.execute(connection)
    query.started_at.should == now
  end

  it "updates finish time when executing" do
    Time.stub(:now).and_return(now = stub)
    connection = stub(:execute => [['id', 'name'], [1, 'Paul']])
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.execute(connection)
    query.finished_at.should == now
  end

  it "updates finish time when execution fails" do
    Time.stub(:now).and_return(now = stub)
    connection = stub
    connection.stub(:execute).and_raise(Oculus::Connection::Error.new('You have an error in your SQL syntax'))
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.execute(connection)
    query.finished_at.should == now
  end

  it "has a name" do
    query = Oculus::Query.new(:name => 'foo')
    query.name.should == 'foo'
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

  it "is not complete when it has not been executed" do
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.should_not be_complete
  end

  it "is complete when it has been executed" do
    connection = stub(:execute => [['id', 'name'], [1, 'Paul']])
    query = Oculus::Query.new
    query.execute(connection)
    query.should be_complete
  end

  it "is complete when there is an error" do
    connection = stub
    connection.stub(:execute).and_raise(Oculus::Connection::Error.new('You have an error in your SQL syntax'))
    query = Oculus::Query.new
    query.execute(connection)
    query.should be_complete
  end

  it "is not successful when it's not complete" do
    query = Oculus::Query.new(:query => 'SELECT * FROM users')
    query.succeeded?.should be false
  end

  it "is successful when results are present" do
    connection = stub(:execute => [['id', 'name'], [1, 'Paul']])
    query = Oculus::Query.new
    query.execute(connection)
    query.succeeded?.should be true
  end

  it "is not successful when there is an error" do
    connection = stub
    connection.stub(:execute).and_raise(Oculus::Connection::Error.new('You have an error in your SQL syntax'))
    query = Oculus::Query.new
    query.execute(connection)
    query.succeeded?.should be false
  end
end
