require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require "#{File.dirname(__FILE__)}/app-sinatra"

set :environment, ENV['RACK_ENV'].to_sym
set :root,        ROOT
set :app_file,    File.join(ROOT, 'app-sinatra.rb')
disable :run

run Sinatra::Application
