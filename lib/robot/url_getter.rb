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
    ::SimpleHttp.get(@url).tap do |response|
      status, headers, blob = *response
      response[2] = Magick::Image.from_blob(blob).first if status == 200
    end
  end
  
  def configure!(path)
    @url = "#{scheme}#{path.fetch_remainder}"
  end
end
