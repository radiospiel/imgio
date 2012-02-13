# coding: utf-8
require "sinatra"
require "sinatra/synchrony"
if development?
  require "sinatra/reloader"
  also_reload 'lib/**/*'
end
# RMagick spits out a ton of warnings "already initialized constant"
verbose_was = $VERBOSE
$VERBOSE=nil; require 'RMagick'
$VERBOSE = verbose_was

require_relative "lib/magick_processor"
require_relative "lib/http"

disable :threaded
disable :run
set :mime_types, {
  'jpg'  => 'image/jpeg',
  'gif'  => 'image/gif',
  'png'  => 'image/png'
  }.tap {|h| h.default = "application/octet-stream" }

before do
  expires 24*3600, :public
end

# GET [mode]/[format[quality]]/width/height/uri
get %r{/(?:(scale_down|fit|fill)/)?(?:((?:jpg(?:\d{1,3})?|png))/)?(\d+)/(?:(\d+)/)(https?.+)} do |mode, formatstring, width, height, uri|
  # TODO: fix this abnormality. Sinatra eats the second slash from http://.
  #       No, I am serious, it is just gone in the captures.
  uri.sub!(/(https?):\/\/?/) { "#{$1}://" }
  
  mode ||= :scale_down
  formatstring ||= 'jpg85'
  /(?<format>[a-z]+)(?<quality>\d+)?/i =~ formatstring
  content_type settings.mime_types[format]
  Magick.process(mode, format, quality, width, height, uri)
end

get '/*' do
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
