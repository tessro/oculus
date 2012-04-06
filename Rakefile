#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require 'cucumber/rake/task'

desc 'Run RSpec tests'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = %w[--color --format documentation]
  task.pattern    = 'spec/*_spec.rb'
end

desc 'Run Cucumber features'
Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = 'features --format pretty'
end

task :default => [:spec, :cucumber]
