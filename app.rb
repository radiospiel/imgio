#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'curb'
require 'uri'
require 'rmagick'

TIME_TO_LIVE = 24 * 3600      # default expiration time: 1 day


class Magick::Image
  
  # scale image down, but never up.
  def scale_down(width, height)
    change_geometry("#{width}x#{height}") do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end
  end

    # dst = Magick::Image.new(300,200)
    # result = dst.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)

  # load an image from an URL
  def self.from_url(url)
    curl = Curl::Easy.new(url)
    curl.follow_location = true
    curl.perform

    Magick::Image.from_blob(curl.body_str)
  end
end


#
# Say hi!
get '/' do
  'Hello, world!'
end

get %r{(/(jpg|png)([0-9]{1,3}))(/([0-9]{1,4})(/([0-9]{1,4})))/((http|https)://.*)} do

  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]

  # try to parse url. Failure -> exception
  uri = URI.parse(url)

  # fetch image from URL
  img = Magick::Image.from_url(url).first

  # process image
  img.scale_down(width, height)
  
  # write out image
  blob = img.to_blob do |img|
    img.format = "PNG"
  end
  
  content_type mime_type_for(uri.path)
  content_length blob.length

  # see http://devcenter.heroku.com/articles/http-caching
  expires TIME_TO_LIVE, :public

  blob
end

       
#
# various helpers
helpers do

  MIME_TYPES = {
    '.jpeg' => 'image/jpeg',
    '.jpg'  => 'image/jpeg',
    '.gif'  => 'image/gif',
    '.png'  => 'image/png'
  }
  
  def mime_type_for(path)
    MIME_TYPES[File.extname(path).downcase] || "application/octet-stream"
  end

  def content_length(length)
    response['Content-Length'] = length.to_s
  end
end
