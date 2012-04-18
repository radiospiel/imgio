# A robot to read from an URL.
class Robot::UrlGetter < Robot
  alias :scheme :name

  # Note: while other robots take two parameters (headers, data) that 
  # define the input the robot is working on, the UrlGetter robot does not 
  # do that.
  #
  # The UrlGetter's result is the data which is read from the URL specified
  # via configure! (which, on a side note, makes sure that an UrlGetter is
  # always the first robot in an AssemblyLine, as it fetches the remaining 
  # path completely.
  def run
    blob = Http.get @url
    image = Magick::Image.from_blob(blob).first
    [ {}, image ]
  end
  
  def configure!(path)
    @url = "#{scheme}#{path.fetch_remainder}"
  end
end
