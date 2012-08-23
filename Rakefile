# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "thrift-sqs-transport"
  gem.homepage = "http://github.com/elseano/thrift-sqs-transport"
  gem.license = "MIT"
  gem.summary = %Q{A transport for Thrift using Amazon's Simple Queue Service.}
  gem.description = %Q{A transport for Thrift using Amazon's Simple Queue Service.}
  gem.email = "sean.stquentin@gmail.com"
  gem.authors = ["Sean St. Quentin"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

