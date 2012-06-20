#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'mysql2'
require 'pg'

desc 'Run RSpec tests'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = %w[--color --format documentation]
  task.pattern    = 'spec/*_spec.rb'
end

desc 'Run Cucumber features'
Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = 'features --format pretty'
end

namespace :db do
  namespace :test do
    desc "Populate the test database"
    task :populate do
      # MySQL
      #
      client = Mysql2::Client.new(:host => "localhost", :username => "root")
      client.query "CREATE DATABASE IF NOT EXISTS oculus_test"
      client.query "USE oculus_test"
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

      client.close

      # Postgres
      #
      client = PG::Connection.new(:host => "localhost", :user => "postgres", :dbname => "postgres")
      client.query "DROP DATABASE IF EXISTS oculus_test"
      client.query "CREATE DATABASE oculus_test"
      client.close

      client = PG::Connection.new(:host => "localhost", :user => "postgres", :dbname => "oculus_test")
      client.query %[
        CREATE TABLE oculus_users (
          id INT NOT NULL UNIQUE,
          name VARCHAR(255)
        );
      ]

      client.query %[
        INSERT INTO oculus_users (id, name) VALUES (1, 'Paul'), (2, 'Amy'), (3, 'Peter')
      ]

      client.close
    end
  end
end

task :default => [:spec, :cucumber]
