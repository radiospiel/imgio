require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require "app"

set :environment, ENV['RACK_ENV'].to_sym
set :root,        ROOT
set :app_file,    File.join(ROOT, 'app.rb')
disable :run

run Sinatra::Application

STDERR.puts "Loaded app"
