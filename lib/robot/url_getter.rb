# A robot to read from an URL.
class Robot::UrlGetter < Robot
  alias :scheme :name

  # Note: while other robots take status, headers, data parameters to define
  # the input this robot is working on, the UrlGetter robot does not do that.
  #
  # The UrlGetter's result is the data which is read from the URL specified
  # via configure! (which, on a side note, makes sure that an UrlGetter is
  # always the first robot in an AssemblyLine, as it fetches the remaining 
  # path completely.
  def run
    blob = ::SimpleHttp.get @url

    image = Magick::Image.from_blob(blob).first
    [ 200, {}, image ]
  end
  
  def configure!(path)
    @url = "#{scheme}#{path.fetch_remainder}"
  end
end
