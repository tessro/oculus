require 'oculus'

describe Oculus::Storage::FileStore do
  subject { Oculus::Storage::FileStore.new('tmp/test_cache') }

  let(:query) do
    Oculus::Query.new(:description => "All users",
                      :query       => "SELECT * FROM oculus_users",
                      :author      => "Paul",
                      :results     => [['id', 'users'], ['1', 'Paul'], ['2', 'Amy']])
  end

  let(:other_query) do
    Oculus::Query.new(:description => "Admin users",
                      :query       => "SELECT * FROM oculus_users WHERE is_admin = 1",
                      :author      => "Paul",
                      :results     => [['id', 'users'], ['2', 'Amy']])
  end

  before do
    Dir.mkdir('tmp/test_cache')
  end

  after do
    FileUtils.rm_r('tmp/test_cache')
  end

  it "round-trips a query to disk" do
    subject.save_query(query)
    subject.load_query(query.id).results.should == query.results
    subject.load_query(query.id).query.should == query.query
    subject.load_query(query.id).author.should == query.author
    subject.load_query(query.id).id.should == query.id
  end

  it "returns nil for missing queries" do
    subject.load_query(39827493).should be nil
  end

  it "fetches all queries" do
    subject.save_query(query)
    subject.save_query(other_query)

    subject.all_queries.map(&:results).should == [query.results, other_query.results]
  end
end
