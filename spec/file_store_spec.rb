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
    subject.load_query(query.id).results.should == []
    subject.load_query(query.id).query.should == query.query
    subject.load_query(query.id).started_at.should == query.started_at
    subject.load_query(query.id).finished_at.should == query.finished_at
    subject.load_query(query.id).author.should == query.author
    subject.load_query(query.id).id.should == query.id
    subject.load_query(query.id).thread_id.should == query.thread_id
  end

  it "round-trips a query with an error to disk" do
    subject.save_query(broken_query)
    subject.load_query(broken_query.id).results.should == []
    subject.load_query(broken_query.id).error.should == broken_query.error
    subject.load_query(broken_query.id).query.should == broken_query.query
    subject.load_query(broken_query.id).started_at.should == broken_query.started_at
    subject.load_query(broken_query.id).finished_at.should == broken_query.finished_at
    subject.load_query(broken_query.id).author.should == broken_query.author
    subject.load_query(broken_query.id).id.should == broken_query.id
    subject.load_query(broken_query.id).thread_id.should == broken_query.thread_id
  end

  it "round-trips a query to disk" do
    subject.save_query(query)
    subject.load_query(query.id).results.should == query.results
    subject.load_query(query.id).query.should == query.query
    subject.load_query(query.id).started_at.should == query.started_at
    subject.load_query(query.id).finished_at.should == query.finished_at
    subject.load_query(query.id).author.should == query.author
    subject.load_query(query.id).id.should == query.id
    subject.load_query(query.id).thread_id.should == query.thread_id
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

  it "deletes queries" do
    subject.save_query(query)
    subject.load_query(query.id).name.should == query.name
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
