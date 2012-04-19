require 'rake/testtask'
desc "Run tests"
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'tests/**/*_test.rb'
  test.verbose = true
end

task :default => :test
