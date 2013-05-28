if EVENT_MACHINED
  require 'em-synchrony/em-http'
else
  require "net/http"
  require "uri"
end

# The SimpleHttp module exports SimpleHttp.get, which returns the body of an URL, and is able to follow
# a certain number of redirections. Note: This module is named "SimpleHttp" to prevent a name clash with
# VCR and/or WebMock.
module SimpleHttp
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
    # returns [ status, headers, body ]
    def get(url, max_redirections = MAX_REDIRECTIONS)
      raise ArgumentError, 'HTTP redirect too deep' if max_redirections == 0

      uri = URI.parse(url)

      # build HTTP connection
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Danger! But https://a0.twimg.com wouldn't work.
      
      # get response
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      # redirect?
      return get(response['location'], max_redirections - 1) if response.is_a?(Net::HTTPRedirection)

      # build return value
      headers = {}
      response.each_capitalized do |key, value|
        headers.store key, value
      end
      
      [ response.code.to_i, headers, response.body ]
    end
  end

  extend EVENT_MACHINED ? Async : Sync
end
