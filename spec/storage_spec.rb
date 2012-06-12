require 'oculus'
require 'oculus/storage/sequel_store'

shared_examples "storage" do |subject|
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

  it "round-trips a query with no results" do
    query = Oculus::Query.new(:name => "Unfinished query", :author => "Me")
    storage.save_query(query)
    storage.load_query(query.id).should == {
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

  it "round-trips a query with an error" do
    storage.save_query(broken_query)
    storage.load_query(broken_query.id).should == {
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

  it "round-trips a query" do
    storage.save_query(query)
    storage.load_query(query.id).should == {
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
    storage.save_query(query)
    original_id = query.id
    storage.save_query(query)
    query.id.should == original_id
  end

  it "raises QueryNotFound for missing queries" do
    lambda {
      storage.load_query(39827493)
    }.should raise_error(Oculus::Storage::QueryNotFound)
  end

  it "fetches all queries in reverse chronological order" do
    storage.save_query(query)
    storage.save_query(other_query)

    storage.all_queries.map(&:results).should == [other_query.results, query.results]
  end

  it "fetches starred queries" do
    query.starred = true
    storage.save_query(query)
    storage.save_query(other_query)

    results = storage.starred_queries
    results.map(&:results).should == [query.results]
    results.first.starred.should be true
  end

  it "deletes queries" do
    storage.save_query(query)
    storage.load_query(query.id)[:name].should == query.name
    storage.delete_query(query.id)

    lambda {
      storage.load_query(query.id)
    }.should raise_error(Oculus::Storage::QueryNotFound)
  end

  it "raises QueryNotFound when deleting a nonexistent query" do
    lambda {
      storage.delete_query(10983645)
    }.should raise_error(Oculus::Storage::QueryNotFound)
  end

  it "sanitizes query IDs" do
    lambda {
      storage.delete_query('..')
    }.should raise_error(ArgumentError)
  end
end

describe Oculus::Storage::FileStore do
  it_behaves_like "storage" do
    let(:storage) { Oculus::Storage::FileStore.new('tmp/test_cache') }

    before do
      FileUtils.mkdir_p('tmp/test_cache')
    end

    after do
      FileUtils.rm_r('tmp/test_cache')
    end

    context "when cache dir does not exist (like for a new install)" do
      before do
        FileUtils.rm_r('tmp/test_cache')
      end

      it "round-trips a query to disk" do
        storage.save_query(query)
        storage.load_query(query.id).should == {
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
    end
  end
end

describe Oculus::Storage::SequelStore do
  it_behaves_like "storage" do
    let(:storage) { Oculus::Storage::SequelStore.new('postgres://localhost/oculus_test') }

    before do
      storage.drop_table
      storage.create_table
    end
  end
end
