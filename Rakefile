#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require 'cucumber/rake/task'

namespace :test do
  desc 'Run RSpec tests'
  RSpec::Core::RakeTask.new(:specs) do |task|
    task.rspec_opts = %w[--color --format documentation]
    task.pattern    = 'spec/*_spec.rb'
  end

  desc 'Run Cucumber features'
  Cucumber::Rake::Task.new(:features) do |task|
    task.cucumber_opts = 'features --format pretty'
  end

  task :all => [:specs, :features]
end

task :default => 'test:all'
