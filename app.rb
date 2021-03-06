# coding: utf-8
EVENT_MACHINED=ENV['RACK_ENV'] != 'test'

require "sinatra"
require "sinatra/synchrony" if EVENT_MACHINED
require "mime/types"

if development?
  require "sinatra/reloader"
  also_reload 'lib/**/*'
end

require "RMagick" unless defined?(Magick)

# If path_traversal protection is enabled rack-protection eats double
# slashes in the URL. As 3rd party URLs are part of imgio URLs, this
# would break the parameter parsing.
set :protection, :except => :path_traversal

set :static, true

STDERR.puts "Enable PageCache in #{settings.public_folder}"
require "rack/page_cache"
use Rack::PageCache, settings.public_folder

require "#{File.dirname(__FILE__)}/lib/http"
require "#{File.dirname(__FILE__)}/lib/robot"
require "#{File.dirname(__FILE__)}/lib/assembly_line"

disable :threaded if EVENT_MACHINED

disable :run

# By default rack-protection removes double slashes, we do need them.
set :protection, :except => :path_traversal

get(/\/./) do
  begin
    path_with_query = request.path

    query_string = request.env["QUERY_STRING"].to_s
    path_with_query += "?#{query_string}" unless query_string.empty?

    assembly_line = AssemblyLine.new(path_with_query)

    status, headers, body = assembly_line.run

    # Note that Robot::Png is able to run without a configure! step.
    if status == 200 && body.is_a?(Magick::Image)
      status, headers, body = Robot::Writer::Png.new.run(status, headers, body)
    end

    # Delete headers we don't want.
    headers.keys.each do |key|
      next unless key =~ /^(X-|Via$|P3p|Pragma$|Content-Length$)/
      headers.delete key
    end

    self.headers headers
    self.status status

    expires 24*3600, :public
    
    body
  rescue Errno::ENOENT 
    raise Sinatra::NotFound
  end
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
