require 'RMagick' if !defined?(Magick)

require 'curb'

# --- RMagick extensions ------------------------------------------------------

class Magick::Image

  # scale image down, but never up.
  def scale_down(width, height, format)
    change_geometry("#{width}x#{height}") do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end

    self
  end

  # scale image up to fill widthxheight image
  def fill(width, height, format)
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
  def fit(width, height, format)
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
      self.background_color = format == "png" ? "none" : "white"
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
