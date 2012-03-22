require 'oculus'

describe Oculus::Query do
  before do
    Oculus::Query.data_store = stub
  end

  it "stores new queries in the data store" do
    Oculus::Query.data_store.should_receive(:save_query)
    query = Oculus::Query.create(:results => [['id', 'name'], [1, 'Paul']])
  end

  it "retrieves cached queries from the data store" do
    Oculus::Query.data_store.should_receive(:find_query).with(1)
    Oculus::Query.find(1)
  end
end
