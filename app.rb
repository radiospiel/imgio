#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'curb'
require 'dlog'
require 'uri'
require 'rmagick'

#
# default expiration time: 1 day
TIME_TO_LIVE = 24 * 3600
Dlog.logger = Logger.new "#{File.dirname(__FILE__)}/log/app.log"

class String
  def blank?; empty? end
end

class NilClass
  def blank?; empty? end
end

#
# Some stats
get '/' do
  'Hello, world!'
end

get %r{(/(jpg|png)([0-9]{1,3}))(/([0-9]{1,4})(/([0-9]{1,4})))/((http|https)://.*)} do

  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]

  # try to parse url. Failure -> exception
  uri = URI.parse(url)

  # fetch image from URL
  img = load_image_from_url(url)

  # process image
  img = scale_image(img, width.to_f, height.to_f)
  
  # write out image
  blob = img.to_blob do |img|
    img.format = "PNG"
  end
  
  content_type mime_type_for(uri.path)
  content_length blob.length

  # last_modified stat.mtime
  # expires 500, :public, :must_revalidate
  blob
end

       
#
# helpers
helpers do

  # scale image
  def scale_image(img, width, height)
    img.change_geometry("#{width}x#{height}") do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end
    
    
    # do we have to extend the image to match the requested size, scaling notwithstanding?
    # get width/height scaled to image size
    # if scaled width and height match  

    dst = Magick::Image.new(300,200)
    result = dst.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)
  end
  
  # load an image from an URL
  def load_image_from_url(url)
    curl = Curl::Easy.new(url)
    curl.follow_location = true
    curl.perform

    images = Magick::Image.from_blob(curl.body_str)
    images.first
  end

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
