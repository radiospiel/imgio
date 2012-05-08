#
# prepare everything to run all tests.

ENV['RACK_ENV'] = 'test'
Bundler.setup(:default)
require "#{File.dirname(__FILE__)}/../app.rb"
require 'test/unit'
require "mocha"

Bundler.require(:test)

require "ruby-debug"

Sinatra::Synchrony.patch_tests! if EVENT_MACHINED

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/fixtures-vcr"
  c.hook_into :webmock
end

class ImgioTestCase < Test::Unit::TestCase
  def setup
    VCR.insert_cassette('imgio', :record => :new_episodes)
  end
  
  def teardown
    VCR.eject_cassette
  end
end
