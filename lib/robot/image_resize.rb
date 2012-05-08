class Robot::Resize < Robot
  attr :width, :height
  
  def configure!(path)
    geometry = path.fetch("\\d+x\\d+") || invalid_path!(path.to_s)
    @width, @height = geometry.split("x").map(&:to_i)
  end

  # This method returns true if the passed in image has the requested geometry.
  # def matches_geometry?(image)
  #   image.columns == @width && image.rows == @height
  # end
  
  def scale_down(image, geometry)
    image.change_geometry(geometry) do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end
  end
end


# I don't know if we need that one as a standalone robot.
=begin
class Robot::Scale < Robot::Resize
  def run(status, headers, image)
    result = image.change_geometry(geometry) do |cols, rows, img|
      next if cols >= img.columns || rows >= img.rows
      img.resize!(cols, rows)
    end

    [ 200, headers, result ]
  end
end
=end

class Robot::Fill < Robot::Resize
  def run(status, headers, image)
    resized = scale_down(image, "#{width}x#{height}^") || image

    # get scale factor: the image might not have been resized, because
    # it is smaller than what was requested already.
    scale = [resized.columns.to_f / width, resized.rows.to_f / height].min

    result = Magick::Image.new(width * scale, height * scale)
    result = result.composite(resized, Magick::CenterGravity, Magick::OverCompositeOp)
    
    [ 200, headers, result ]
  end
end

class Robot::Fit < Robot::Resize
  def run(status, headers, image)
    resized = scale_down(image, "#{width}x#{height}") || image

    # get scale factor: the image might not have been resized, because
    # it is smaller than what was requested already.
    scale = [resized.columns.to_f / width, resized.rows.to_f / height].max

    result = Magick::Image.new(width * scale,height * scale) {
      # self.background_color = format == "png" ? "none" : "white"
      self.background_color = "none"
    }

    result = result.composite(resized, Magick::CenterGravity, Magick::OverCompositeOp)
    
    [ 200, headers, result ]
  end
end
