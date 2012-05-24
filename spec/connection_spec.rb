require 'oculus'

describe Oculus::Connection do
  describe "non-nonexistent adapter" do
    it "raises an adapter not found error" do
      lambda {
        Oculus::Connection.connect adapter: 'nonexistent-adapter'
      }.should raise_error Oculus::Connection::AdapterNotFound, "nonexistent-adapter is not currently implemented. You should write it!"
    end
  end

  describe "mysql adapter option" do
    it "returns a new instance of MySQL adapter" do
      adapter = Oculus::Connection.connect adapter: 'mysql'
      adapter.should be_an_instance_of Oculus::Connection::Mysql2
    end
  end

  describe "postgres adapter option" do
    it "returns a new instance of Postgres adapter" do
      adapter = Oculus::Connection.connect adapter: 'postgres', database: 'oculus_test'
      adapter.should be_an_instance_of Oculus::Connection::Postgres
    end
  end

  describe "pg adapter alias" do
    it "returns a new instance of Postgres adapter" do
      adapter = Oculus::Connection.connect adapter: 'pg', database: 'oculus_test'
      adapter.should be_an_instance_of Oculus::Connection::Postgres
    end
  end
end

