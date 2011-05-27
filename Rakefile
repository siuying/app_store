require 'rubygems'
require "rake/testtask"
require "test/unit"

require "rubygems"
require "bundler"
Bundler.require(:default, :development)

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test*.rb']
  t.verbose = true
end