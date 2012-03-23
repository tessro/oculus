require 'oculus'

describe Oculus::Storage::FileStore do
  subject { Oculus::Storage::FileStore.new('tmp/data') }

  let(:query) do
    Oculus::Query.new(:description => "All users",
                      :query       => "SELECT * FROM oculus_users",
                      :results     => [['id', 'users'], ['1', 'Paul'], ['2', 'Amy']])
  end

  it "round-trips a query to disk" do
    subject.save_query(query)
    subject.load_query(query.id).results.should == query.results
    subject.load_query(query.id).query.should == query.query
  end
end
