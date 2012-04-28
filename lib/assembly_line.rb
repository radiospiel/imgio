class AssemblyLine
  #
  # The AssemblyLine::Path class is used to parse an AssemblyLine
  # description string and configure the AssemblyLine robots.
  class Path
    def initialize(string)
      @original_string, @string = string.dup.freeze, string
    end

    def to_s
      @original_string
    end
    
    # fetch the first word (in-rex is nil) or the first match of in_rex.
    # Note that the match is anchored at the beginning and enclosed in slashes;
    # i.e. fetch("foo") would match "/foo/...", but neither "/bar-foo/..." 
    # nor "/foo-bar/..."
    def fetch(in_rex = nil)
      return unless @string
      
      # take the passed-in rex, and make it anchor at the first char and 
      # just before a slash. The default Regexp reads like this: match a
      # beginning "/" followed by a number of non-slashes, if again followed
      # by a trailing slash.
      rex = in_rex.nil? ? %r{^/([^/]+)(?=/)} : Regexp.compile("^/(#{in_rex})(?=/)")

      # "cut out" the first match using the regexp.
      remainder, first = @string.sub(rex, ""), $1
      return unless first
      
      # Eat the match, i.e. replace the string with the remainder.
      @string = remainder
      first
    end
    
    # Fetches the name of the next robot, and builds and configures it.
    def build_robot
      return unless word = self.fetch
      AssemblyLine.new_robot(word).tap { |robot| robot.configure!(self) }
    end

    def fetch_remainder
      r, @string = @string, nil
      r
    end
  end

  attr :robots
  
  def initialize(path_in)
    @robots = []
    
    path = Path.new(path_in)
    while robot = path.build_robot do
      @robots.unshift(robot)
    end
  end
  
  def self.register_robot_klass(name, klass)
    @robots ||= Hash.new { |hash, name| raise(ArgumentError, "Invalid robot #{name.inspect}") }
    @robots[name] = klass
  end

  # creates a Robot instance for the \a name.
  def self.new_robot(name)
    @robots[name].new(name)
  end
  
  def run
    @robots.inject(nil) do |data, robot|
      robot.run(*data)
    end
  end
end


AssemblyLine.register_robot_klass "jpg",    Robot::Writer::Jpg
AssemblyLine.register_robot_klass "png",    Robot::Writer::Png
AssemblyLine.register_robot_klass "gif",    Robot::Writer::Gif
AssemblyLine.register_robot_klass "http:",  Robot::UrlGetter
AssemblyLine.register_robot_klass "https:", Robot::UrlGetter
AssemblyLine.register_robot_klass "fill",   Robot::Fill
AssemblyLine.register_robot_klass "fit",    Robot::Fit
