if ASYNC
  require 'em-synchrony/em-http'
else
  require "net/http"
  require "uri"
end

#
# The Http module exports Http.get, which returns the body of an URL, and is able to follow
# a certain number of redirections.
module Http
  MAX_REDIRECTIONS = 10
  
  def self.get(url, max_redirections = 10)
    start = Time.now
    status, body = I.get(url)
    
    dlog "#{url}: #{status}, #{body.length} byte, #{((Time.now - start) * 1000).to_i} msecs via #{I}"
    
    body
  end

  module Sync
    def self.get(url, max_redirections = MAX_REDIRECTIONS)
      raise ArgumentError, 'HTTP redirect too deep' if max_redirections == 0

      response = Net::HTTP.get_response(URI.parse(url))

      case response
      when Net::HTTPSuccess     then [ response['status'], response.body ]
      when Net::HTTPRedirection then get(response['location'], max_redirections - 1)
      else                           response.error!
      end
    end
  end

  module Async
    def self.get(url, max_redirections = MAX_REDIRECTIONS)
      raise ArgumentError, 'HTTP redirect too deep' if max_redirections == 0

      connection = EM::HttpRequest.new(url).get

      case status = connection.response_header.status
      when 300, 301, 302, 303, 304, 305, 307
        get connection.response_header['location'], max_redirections - 1
      when 200
        [status, connection.response]
      else
        raise RuntimeError, "#{url}: #{connection.response_header.status}"
      end
    end
  end

  I = ASYNC ? Async : Sync 
end
