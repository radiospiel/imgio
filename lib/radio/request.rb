
class Radio::Request
  attr_reader :env, :uri
  
  def initialize(env)
    @env = env
    @uri = "http://#{env["SERVER_NAME"]}:#{env["SERVER_PORT"]}#{env["REQUEST_URI"]}"
  end

  def params
    env["params"]
  end

  private
  
  def request_method; env["REQUEST_METHOD"]; end

  public
  
  def get?; request_method == "GET"; end
  def put?; request_method == "PUT"; end
  def post?; request_method == "POST"; end

  def path; env["PATH_INFO"]; end
  
  def process
    controller_klass = Radio::Loader.controller_class_for(path) || Radio::LogController
    dlog "Performing using #{controller_klass}"

    c = controller_klass.new(self)
    c.process!
    [ c.status, c.headers, c.body ]
  end

  def inspect
    env.map do |k,v|
      "#{k}: #{v}" if k == k.upcase
    end.compact.sort.join("\n")
  end
end
