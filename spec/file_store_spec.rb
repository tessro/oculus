require 'oculus'

describe Oculus::Storage::FileStore do
  subject { Oculus::Storage::FileStore.new('tmp/test_cache') }

  let(:query) do
    Oculus::Query.new(:name      => "All users",
                      :query     => "SELECT * FROM oculus_users",
                      :author    => "Paul",
                      :thread_id => 42,
                      :results   => [['id', 'users'], ['1', 'Paul'], ['2', 'Amy']])
  end

  let(:other_query) do
    Oculus::Query.new(:name      => "Admin users",
                      :query     => "SELECT * FROM oculus_users WHERE is_admin = 1",
                      :author    => "Paul",
                      :thread_id => 42,
                      :results   => [['id', 'users'], ['2', 'Amy']])
  end

  let(:broken_query) do
    Oculus::Query.new(:name      => "Admin users",
                      :query     => "FOO BAZ QUUX",
                      :author    => "Paul",
                      :thread_id => 42,
                      :error     => "You have an error in your SQL syntax")
  end

  before do
    FileUtils.mkdir_p('tmp/test_cache')
  end

  after do
    FileUtils.rm_r('tmp/test_cache')
  end

  it "round-trips a query with no results to disk" do
    query = Oculus::Query.new(:name => "Unfinished query", :author => "Me")
    subject.save_query(query)
    subject.load_query(query.id).should == {
      :id => query.id,
      :name => query.name,
      :author => query.author,
      :query => query.query,
      :results => [],
      :thread_id => query.thread_id,
      :starred => false,
      :started_at => query.started_at,
      :finished_at => query.finished_at
    }
  end

  it "round-trips a query with an error to disk" do
    subject.save_query(broken_query)
    subject.load_query(broken_query.id).should == {
      :id => broken_query.id,
      :name => broken_query.name,
      :error => broken_query.error,
      :author => broken_query.author,
      :query => broken_query.query,
      :results => [],
      :thread_id => broken_query.thread_id,
      :starred => false,
      :started_at => broken_query.started_at,
      :finished_at => broken_query.finished_at
    }
  end

  it "round-trips a query to disk" do
    subject.save_query(query)
    subject.load_query(query.id).should == {
      :id => query.id,
      :name => query.name,
      :author => query.author,
      :query => query.query,
      :results => query.results,
      :thread_id => query.thread_id,
      :starred => false,
      :started_at => query.started_at,
      :finished_at => query.finished_at
    }
  end

  it "doesn't overwrite an existing query id when saving" do
    subject.save_query(query)
    original_id = query.id
    subject.save_query(query)
    query.id.should == original_id
  end

  it "raises QueryNotFound for missing queries" do
    lambda {
      subject.load_query(39827493)
    }.should raise_error(Oculus::Storage::QueryNotFound)
  end

  it "fetches all queries in reverse chronological order" do
    subject.save_query(query)
    subject.save_query(other_query)

    subject.all_queries.map(&:results).should == [other_query.results, query.results]
  end

  it "fetches starred queries" do
    query.starred = true
    subject.save_query(query)
    subject.save_query(other_query)

    results = subject.starred_queries
    results.map(&:results).should == [query.results]
    results.first.starred.should be true
  end

  it "deletes queries" do
    subject.save_query(query)
    subject.load_query(query.id)[:name].should == query.name
    subject.delete_query(query.id)

    lambda {
      subject.load_query(query.id)
    }.should raise_error(Oculus::Storage::QueryNotFound)
  end

  it "raises QueryNotFound when deleting a nonexistent query" do
    lambda {
      subject.delete_query(10983645)
    }.should raise_error(Oculus::Storage::QueryNotFound)
  end

  it "sanitizes query IDs" do
    lambda {
      subject.delete_query('..')
    }.should raise_error(ArgumentError)
  end
end
