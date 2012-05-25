require 'oculus'
require 'oculus/connection/mysql2'

describe Oculus::Connection::Mysql2 do
  subject { Oculus::Connection::Mysql2.new(:host => 'localhost', :database => 'oculus_test', :username => 'root') }

  it "fetches a result set" do
    subject.execute("SELECT * FROM oculus_users").should == [['id', 'name'], [1, 'Paul'], [2, 'Amy'], [3, 'Peter']]
  end

  it "returns nil for queries that don't return result sets" do
    query_connection = Mysql2::Client.new(:host => "localhost", :database => "oculus_test", :username => "root")
    thread_id = query_connection.thread_id
    Thread.new {
      query_connection.execute("SELECT * FROM oculus_users WHERE SLEEP(2)")
    }

    sleep 0.1
    subject.kill(thread_id).should be_nil
  end

  it "raises a Connection::Error on syntax errors" do
    lambda {
      subject.execute("FOO BAZ QUUX")
    }.should raise_error(Oculus::Connection::Error)
  end

  it "raises a Connection::Error when the query is interrupted" do
    thread_id = subject.thread_id
    Thread.new {
      sleep 0.1
      Mysql2::Client.new(:host => "localhost", :username => "root").query("KILL QUERY #{thread_id}")
    }

    lambda {
      subject.execute("SELECT * FROM oculus_users WHERE SLEEP(2)")
    }.should raise_error(Oculus::Connection::Error)
  end

  it "provides the connection's thread_id" do
    subject.thread_id.should be_an Integer
  end
end
