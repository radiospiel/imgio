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

  assembly_line = AssemblyLine.new(path_with_query)
  
  status, headers, body = assembly_line.run

  # Note that Robot::Png is able to run without a configure! step.
  if status == 200 && body.is_a?(Magick::Image)
    status, headers, body = Robot::Writer::Png.new.run(status, headers, body)
  end

  self.headers headers
  body
end

get '/' do
  content_type "text/plain"
  <<-USAGE
  Welcome to imgio!                                 „Your friendly image asset resizing service“
  
  FORK ME: https://github.com/radiospiel/imgio
  
  EXAMPLES:
  
    GET http://#{request.host_with_port}/fill/120x90/http://www.google.de/images/srpr/logo3w.png
    # => responds with the image filling a rectangle of 120x90

    GET http://#{request.host_with_port}/fit/80x80/http://www.google.de/images/srpr/logo3w.png
    # => responds with the image fitting a rectangle of 80x80

  DOCUMENTATION:
  
    The URL describes an internal workflow. Think of it as a Unix shell pipe in left to right: the source URL 
    goes in, travels through different data processors ('robots'), and finally comes out of the workflow again. 
    The full URL syntax is `http:///#{request.host_with_port}/[robot[/options]]*/uri`. Which and how many, 
    if any, options are valid is specific to each robot.

    imgio currently supports these robots: )

    - **fit/<width>x<height>**: takes an image and produces a new image scaled down to fit into 
      <width> x <height> pixels. The image will never scaled up; if it is too small than 
      width and height will be adjusted to keep the requested aspect ratio.
    - **fill/<width>x<height>**: takes an image and produces a new image scaled down to fit into 
      <width> x <height> pixels. The image will never scaled up; if it is too small than 
      width and height will be adjusted to keep the requested aspect ratio.
    - **png**: convert the image into PNG format. Currently supported only in the left-most position.
    - **jpg[/quality]**: convert the image into JPEG format. Currently supported only in the left-most position.
  
  USAGE
end
