class Robot
  attr :name
  
  def initialize(name=nil)
    @name = name
  end

  # This configures the robot from an AssemblyLine::Path. In doing so it fetches
  # all needed options from the path, potentially modifying the path object.
  def configure!(path)
  end

  #
  # Each robot takes an input and produces an output. Input parameters are
  # - headers: a Hash of headers 
  # - body: the data part. To stay compatible with Rack this, be default, is an
  #   Array of Strings or something similar. Some robots, however, might use
  #   different objects.
  #
  # The call method returns an array [ status, headers, body ]. 
  #
  # The status returned should be 200 for the AssemblyLine to continue. Any other
  # status value will result in aborting the AssemblyLine.
  def run(headers, body)
    raise "Implementation missing!"
  end
  
  def invalid_path!(path)
    raise "Invalid Path #{path}"
  end
end

Dir.glob("#{File.dirname(__FILE__)}/robot/*.rb").sort.each do |file|
  load file
end
