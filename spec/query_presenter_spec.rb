require_relative '../lib/oculus/query'
require_relative '../lib/oculus/presenters/query_presenter'

describe Oculus::Presenters::QueryPresenter do
  let(:query) { Oculus::Query.new }
  let(:presenter) { Oculus::Presenters::QueryPresenter.new(query) }

  it "should delegate to the underlying query" do
    query.name = 'foo'
    presenter.description.should == 'foo'
  end

  it "has a formatted start time" do
    query.started_at = Time.mktime(2010, 1, 1, 12, 34)
    presenter.formatted_start_time.should == '2010-01-01 12:34 PM'
  end

  it "has a formatted finish time" do
    query.finished_at = Time.mktime(2010, 1, 1, 12, 34)
    presenter.formatted_finish_time.should == '2010-01-01 12:34 PM'
  end

  it "has an elapsed time" do
    query.started_at = Time.mktime(2010, 1, 1, 10, 30)
    query.finished_at = Time.mktime(2010, 1, 1, 12, 34)
    presenter.elapsed_time.should == '2 hours 4 minutes'
  end

  it "reports successful queries" do
    query.stub(:complete?).and_return(true)
    presenter.status.should == 'done'
  end

  it "reports failed queries" do
    query.stub(:complete?).and_return(true)
    query.stub(:error).and_return("you fail")
    presenter.status.should == 'error'
  end

  it "reports loading queries" do
    query.stub(:complete?).and_return(false)
    presenter.status.should == 'loading'
  end

  it "uses name for a description when there is one" do
    query.name = "foo"
    presenter.description.should == "foo"
  end

  it "uses SQL for a description when there isn't a name" do
    query.name = nil
    query.query = "SELECT * FROM foo"
    presenter.description.should == "SELECT * FROM foo"
  end

  it "reports that the query has been named" do
    query.name = "Select all the things"
    presenter.should be_named
  end

  it "reports that the query has not been named" do
    query.name = nil
    presenter.should_not be_named
  end
end
