class Robot
  attr :name
  
  def initialize(name=nil)
    @name = name
  end

  # This configures the robot from an AssemblyLine::Path. In doing so it fetches
  # all needed options from the path, potentially modifying the path object.
  def configure!(path)
  end

  # Each robot takes an input and produces an output
  def run(headers, input)
    raise "Implementation missing!"
  end
  
  def invalid_path!(path)
    raise "Invalid Path #{path}"
  end
end

Dir.glob("#{File.dirname(__FILE__)}/robot/*.rb").sort.each do |file|
  load file
end
