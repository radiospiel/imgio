class Radio::LogController < Radio::Controller
  # Override this method!
  def process
    content_type "text/plain"
    request.env.map do |k,v|
      "#{k}: #{v}"
    end.compact.sort.join("\n")
  end
end

class Radio::RootController < Radio::Controller
  def process
    content_type "text/plain"
    self.status = 404
    nil
  end
end
