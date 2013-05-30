require 'rubygems'
require 'rake'
require 'rake/testtask'

desc "Default Task"
task :default => [ :test_all ]

# Run the unit tests

Rake::TestTask.new("test_all") { |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
}

