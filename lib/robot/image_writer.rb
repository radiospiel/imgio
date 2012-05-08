# A robot to write an image.
#
# The Robot::Writer class implements a write_image method which helps
# derived classes to easily implement a run method which converts
# a Magick::Image into proper output.
class Robot::Writer < Robot
  def write_image(headers, image, content_type, &block)
    blob = image.to_blob(&block)
    [ 200, headers.update("Content-Type" => content_type), blob ]
  end
end

# A robot to write a JPEG image.
class Robot::Writer::Jpg < Robot::Writer
  def configure!(path)
    @quality = path.fetch(%r{\d+})
  end

  def run(status, headers, image)
    # Note: the block below has a strange scope; it is not bound to the
    # Robot::Jpg object. Hence we cannot access Robot's internals here, 
    # and must explicitely bind the quality value.
    quality = @quality

    write_image(headers, image, "image/jpg") do |img|
      img.format = "JPG"
      img.quality = quality.to_i if quality
    end
  end
end

# A robot to write a PNG image.
class Robot::Writer::Png < Robot::Writer
  def run(status, headers, image)
    write_image(headers, image, "image/png") do |img|
      img.format = "PNG"
    end
  end
end

# A robot to write a GIF image.
class Robot::Writer::Gif < Robot::Writer
  def run(status, headers, image)
    write_image(headers, image, "image/gif") do |img|
      img.format = "GIF"
    end
  end
end
