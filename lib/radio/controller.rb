
class Radio::Controller
  attr :status, true
  attr :headers, true
  attr :body, true
  attr :request

  def initialize(request)
    @status = 200
    @headers = {}
    @body = nil
    
    @request = request
  end
  
  def process!
    # @body can be set in process, or as the result from process_request
    body = process
    @body ||= body
    self
  end

  protected

  # Override this method!
  def process
    content_type "text/plain"
    @request.uri
  end
  
  def content_type(content_type)
    headers['Content-Type'] = content_type.to_s
  end

  def content_length(content_length)
    headers['Content-Length'] = content_length.to_s
  end
  
  def expires(max_age, mode)
    headers['Cache-Control'] = "#{mode}, max-age=#{max_age}"
  end
end
