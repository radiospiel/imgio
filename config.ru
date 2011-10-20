require 'rubygems'
require 'bundler/setup'
require 'sinatra'

root_dir = File.dirname(__FILE__)

require "#{File.dirname(__FILE__)}/app"

set :environment, ENV['RACK_ENV'].to_sym
set :root,        root_dir
set :app_file,    File.join(root_dir, 'app.rb')
disable :run

run Sinatra::Application

STDERR.puts "Loaded app"
