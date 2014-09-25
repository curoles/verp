=begin rdoc

Description::  VERP rake file
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = Dir[ File.join(File.dirname(__FILE__), "test", "*_test.rb")]
  test.verbose = true
end


task :version do
  puts "VERP version ... TODO"
end
