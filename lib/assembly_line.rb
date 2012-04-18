class AssemblyLine
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
    
    def fetch_remainder
      r, @string = @string, nil
      r
    end
  end

  attr :robots
  
  def initialize(path_in)
    @robots = []
    
    path = Path.new(path_in)
    while robot = build_robot(path) do
      @robots.unshift(robot)
    end
  end
  
  def self.robots
    @robots ||= {}
  end

  def self.register_robot(name, klass)
    robots[name] = klass
  end

  def build_robot(path)
    return unless word = path.fetch

    robot_klass = self.class.robots[word] || "Invalid robot #{word.inspect}"
    robot_klass.new(word).tap { |robot| robot.configure!(path) }
  end
  
  def run
    @robots.inject(nil) do |data, robot|
      robot.run(*data)
    end
  end
end


AssemblyLine.register_robot "jpg",    Robot::Writer::Jpg
AssemblyLine.register_robot "png",    Robot::Writer::Png
AssemblyLine.register_robot "gif",    Robot::Writer::Gif
AssemblyLine.register_robot "http:",  Robot::UrlGetter
AssemblyLine.register_robot "https:", Robot::UrlGetter
AssemblyLine.register_robot "fill",   Robot::Fill
AssemblyLine.register_robot "fit",    Robot::Fit
