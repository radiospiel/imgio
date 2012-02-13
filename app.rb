# coding: utf-8
EVENT_MACHINED=if ENV.key?("IMGIO_EVENT_MACHINED") 
  ENV["IMGIO_EVENT_MACHINED"].to_i != 0
else
  RUBY_VERSION =~ /^1.9/
end

require "sinatra"
require "sinatra/synchrony" if EVENT_MACHINED

if development?
  require "sinatra/reloader"
  also_reload 'lib/**/*'
end

require "#{File.dirname(__FILE__)}/lib/magick_code"
require "#{File.dirname(__FILE__)}/lib/http"

disable :threaded if EVENT_MACHINED

disable :run
set :mime_types, {
  'jpg'  => 'image/jpeg',
  'gif'  => 'image/gif',
  'png'  => 'image/png'
  }.tap {|h| h.default = "application/octet-stream" }

before do
  expires 24*3600, :public
end

helpers do
  
  def process(mode, format, quality, width, height, url)
    # fetch image from URL
    img = Magick::Image.from_blob(Http.get(url)).first

    # get requested image size, fill in height default to match image's aspect ratio.
    width, height = width.to_i, height.to_i
    if height <= 0
      height = img.rows * width / img.columns
    end

    # process image
    img = img.send mode, width.to_i, height.to_i, format

    # write out image
    img.to_blob do |img|
      img.format = format.upcase
      img.quality = quality.to_i
    end
  end
end

# GET [mode]/[format[quality]]/width/height/uri
get %r{/(?:(scale_down|fit|fill)/)?(?:((?:jpg(?:\d{1,3})?|png))/)?(\d+)/(?:(\d+)/)(https?.+)} do |mode, formatstring, width, height, uri|
  # TODO: fix this abnormality. Sinatra eats the second slash from http://.
  #       No, I am serious, it is just gone in the captures.
  uri.sub!(/(https?):\/\/?/) { "#{$1}://" }
  
  mode ||= :scale_down
  formatstring ||= 'jpg85'
  /([a-z]+)(\d+)?/i =~ formatstring
  format, quality = $1, $2
  content_type settings.mime_types[format]
  
  process(mode, format, quality, width, height, uri)
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
