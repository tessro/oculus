require 'oculus'

describe Oculus::Connection do
  before(:all) do
    client = Mysql2::Client.new(:host => "localhost", :username => "root")
    client.query "CREATE DATABASE IF NOT EXISTS test"
    client.query "USE test"
    client.query %[
      CREATE TABLE IF NOT EXISTS oculus_users (
        id MEDIUMINT NOT NULL AUTO_INCREMENT,
        name VARCHAR(255),
        PRIMARY KEY (id)
      );
  ]

    client.query 'TRUNCATE oculus_users'

    client.query %[
      INSERT INTO oculus_users (name) VALUES ('Paul'), ('Amy'), ('Peter')
    ]
  end

  subject { Oculus::Connection::Mysql2.new(:database => 'test') }

  it "fetches a result set" do
    subject.execute("SELECT * FROM oculus_users").should == [['id', 'name'], [1, 'Paul'], [2, 'Amy'], [3, 'Peter']]
  end

  it "returns nil for queries that don't return result sets" do
    query_connection = Mysql2::Client.new(:host => "localhost", :database => "test")
    thread_id = query_connection.thread_id
    Thread.new {
      query_connection.execute("SELECT * FROM oculus_users WHERE SLEEP(2)")
    }

    sleep 0.1
    subject.execute("KILL QUERY #{thread_id}").should be_nil
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
