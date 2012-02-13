require 'em-synchrony/em-http'

# The Http module exports Http.get, which returns the body of an URL, and is able to follow
# a certain number of redirections.
#
module Http
  def self.get(url)
    connection = EM::HttpRequest.new(url).get(:redirects => 10)
    status = connection.response_header.status
    if status >= 200 && status < 300
      connection.response
    else
      raise "Failed to fetch #{url}, status: #{connection.response_header.status}"
    end
  end
end
