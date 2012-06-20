require 'oculus'
require 'oculus/connection/postgres'

describe Oculus::Connection::Postgres do
  subject { Oculus::Connection::Postgres.new(:host => 'localhost', :username => 'postgres', :database => 'oculus_test') }

  it "fetches a result set" do
    subject.execute("SELECT * FROM oculus_users").should == [['id', 'name'],
                                                             ['1', 'Paul'],
                                                             ['2', 'Amy'],
                                                             ['3', 'Peter']]
  end

  it "raises a Connection::Error on syntax errors" do
    lambda {
      subject.execute("FOO BAZ QUUX")
    }.should raise_error(Oculus::Connection::Error)
  end

  it "provides the connection's thread_id" do
    subject.thread_id.should be_an Integer
  end
end
