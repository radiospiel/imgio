if EVENT_MACHINED
  require 'em-synchrony/em-http'
else
  require "net/http"
  require "uri"
end

# The Http module exports Http.get, which returns the body of an URL, and is able to follow
# a certain number of redirections.
#
module Http
  MAX_REDIRECTIONS=10

  module Async
    def get(url)
      connection = EM::HttpRequest.new(url).get(:redirects => MAX_REDIRECTIONS)
      status = connection.response_header.status
      if status >= 200 && status < 300
        connection.response
      else
        raise "Failed to fetch #{url}, status: #{connection.response_header.status}"
      end
    end
  end
  
  module Sync
    def get(url, max_redirections = MAX_REDIRECTIONS)
      raise ArgumentError, 'HTTP redirect too deep' if max_redirections == 0

      case response = Net::HTTP.get_response(URI.parse(url))
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then get(response['location'], max_redirections - 1)
      else                           response.error!
      end
    end
  end

  extend EVENT_MACHINED ? Async : Sync
end
