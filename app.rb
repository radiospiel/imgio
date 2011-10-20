#!/usr/bin/env ruby
require 'RMagick'
require 'curb'

#
# Verbosity: spit out more messages when set 
VERBOSE=true

#
# TTL value ins seconds for Caching headers
TIME_TO_LIVE = 24 * 3600                      # default expiration time: 1 day

require 'uri'

# --- set up logging ----------------------------------------------------------

def rlog(msg)
  STDERR.puts msg
end

def dlog(msg)
  STDERR.puts msg if VERBOSE
end

# -----------------------------------------------------------------------------

# --- RMagick extensions ------------------------------------------------------

class Magick::Image
  
  # scale image down, but never up.
  def scale_down(width, height)
    change_geometry("#{width}x#{height}") do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end
  
    self
  end
  
  # scale image up to fill widthxheight image
  def fill(width, height)
    change_geometry("#{width}x#{height}^") do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end
    
    #
    # get scale factor: the image might not have been resized, because
    # it is smaller than what was requested already.
    scale = [self.columns.to_f / width, self.rows.to_f / height].min
    
    dst = Magick::Image.new(width * scale,height * scale)    
    dst.composite(self, Magick::CenterGravity, Magick::OverCompositeOp)
  end
  
  # scale image to fit into widthxheight image
  def fit(width, height)
    change_geometry("#{width}x#{height}") do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end
    
    #
    # get scale factor: the image might not have been resized, because
    # it is smaller than what was requested already.
    scale = [self.columns.to_f / width, self.rows.to_f / height].max
    
    # cut out 
    dst = Magick::Image.new(width * scale,height * scale) {
      self.background_color = "none"
    }
    dst.composite(self, Magick::CenterGravity, Magick::OverCompositeOp)
  end

  # load an image from an URL
  def self.from_url(url)
    curl = Curl::Easy.new(url)
    curl.follow_location = true
    curl.perform

    dlog "           #{url}: original size: #{curl.body_str.length} byte"

    Magick::Image.from_blob(curl.body_str)
  end
end

# -----------------------------------------------------------------------------

# --- URL parsing -------------------------------------------------------------

#
# Say hi!
get '/' do
  'Hello, world!'
end

get %r{/fit(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)} do
  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]
  process :fit, format, quality, width, height, url 
end

get %r{/fill(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)} do
  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]
  process :fill, format, quality, width, height, url 
end

get %r{(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)} do
  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]
  process :scale_down, format, quality, width, height, url 
end

# -----------------------------------------------------------------------------

# --- various helpers ---------------------------------------------------------

helpers do

  MIME_TYPES = {
    'jpg'  => 'image/jpeg',
    'gif'  => 'image/gif',
    'png'  => 'image/png'
  }
  
  def mime_type_for(format)
    MIME_TYPES[format] || "application/octet-stream"
  end

  def content_length(length)
    response['Content-Length'] = length.to_s
  end

  def process(mode, format, quality, width, height, url)
    # set defaults
    format ||= "jpg"
    quality ||= 85

    rlog "processing #{url}: #{mode} #{format}#{quality} #{width}x#{height}"

    # try to parse url. Failure -> exception
    uri = URI.parse(url)

    # fetch image from URL
    img = Magick::Image.from_url(url).first
    dlog "           #{url}: original geometry: #{img.columns}x#{img.rows}"

    # get requested image size, fill in height default to match image's aspect ratio.
    width, height = width.to_i, height.to_i
    if height <= 0
      height = img.rows * width / img.columns
    end
     
    # process image
    img = img.send mode, width.to_i, height.to_i
    
    # write out image
    blob = img.to_blob do |img|
      img.format = format.upcase
      img.quality = quality.to_i
    end

    dlog "           #{url}: resulting length: #{blob.length} byte"

    content_type mime_type_for(format)
    content_length blob.length

    # see http://devcenter.heroku.com/articles/http-caching
    expires TIME_TO_LIVE, :public

    blob
  end
  
end

# -----------------------------------------------------------------------------

