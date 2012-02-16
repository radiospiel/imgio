require "#{File.dirname(__FILE__)}/magick_code"

module Magick
  def self.process(mode, format, quality, width, height, url)
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
  
  def self.extract_frame(frame, uri)
    imagelist = Magick::ImageList.new.from_blob(Http.get(uri))
    if image = imagelist[frame.to_i]
      image.to_blob
    end
  end
end
