require 'RMagick' if !defined?(Magick)

require "#{File.dirname(__FILE__)}/magick_code"

module Magick
  def self.process(mode, format, quality, width, height, url)
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
    img = img.send mode, width.to_i, height.to_i, format

    # write out image
    blob = img.to_blob do |img|
      img.format = format.upcase
      img.quality = quality.to_i
    end

    dlog "           #{url}: resulting length: #{blob.length} byte"

    blob
  end
end
