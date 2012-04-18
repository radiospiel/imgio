# coding: utf-8
EVENT_MACHINED=if ENV.key?("IMGIO_EVENT_MACHINED") 
  ENV["IMGIO_EVENT_MACHINED"].to_i != 0
else
  RUBY_VERSION =~ /^1.9/
end

EVENT_MACHINED = false

require "sinatra"
require "sinatra/synchrony" if EVENT_MACHINED

if development?
  require "sinatra/reloader"
  also_reload 'lib/**/*'
end

require "RMagick" unless defined?(Magick)

require "#{File.dirname(__FILE__)}/lib/http"
require "#{File.dirname(__FILE__)}/lib/robot"
require "#{File.dirname(__FILE__)}/lib/assembly_line"

disable :threaded if EVENT_MACHINED

disable :run

before do
  expires 24*3600, :public
end


get(/\/./) do
  # Hu? Sinatra (or probably Rack) eats double slashes in request.path?
  request_path = request.path.
    gsub(%r{\b(http|https):/}, "\\1://").
    gsub(%r{\b(http|https):///}, "\\1://")

  query_string = request.env["QUERY_STRING"].to_s

  path_with_query = request_path
  path_with_query += "?#{query_string}" unless query_string.empty?

  assembly_line = AssemblyLine.new path_with_query
  
  result = assembly_line.run

  # Note that Robot::Png is able to run without a configure! step.
  if result.last.is_a?(Magick::Image)
    result = Robot::Writer::Png.new.run(*result)
  end

  headers result.first
  result.last
end

get '/' do
  content_type "text/plain"
  <<-USAGE
  Welcome to imgio!                                 „Your friendly image asset resizing service“
  
  FORK ME: https://github.com/radiospiel/imgio
  
  EXAMPLES:
  
    GET http://#{request.host_with_port}/120/90/http://www.google.de/images/srpr/logo3w.png
    # => responds with the image scaled down to 120x90
  
    GET http://#{request.host_with_port}/fill/120/90/http://www.google.de/images/srpr/logo3w.png
    # => responds with the image filling a rectangle of 120x90
  
    GET http://#{request.host_with_port}/fit/80/80/http://www.google.de/images/srpr/logo3w.png
    # => responds with the image fitting a rectangle of 80x80
  
  DOCUMENTATION:
  
    GET [mode]/[format[quality]]/width/[height]/uri
    
      width, height must be a positive integer
      uri must adhere to URI specification
    
    Defaults:
    
      mode: scale_down
      format: jpg
      quality: 85
      height: whatever height would match the original image's aspect ratio
  
  USAGE
end
