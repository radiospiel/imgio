require 'fileutils'

# PageCache is a Rack middleware that caches responses for successful GET requests
# to disk. This works similar to Rails' page caching, allowing you to cache dynamic
# pages to static files that can be served directly by a front end webserver.
class PageCache
  # Initialize a new ReponseCache object with the given arguments.  Arguments:
  # * app : The next middleware in the chain.  This is always called.
  # * cache : The place to cache responses.  If a string is provided, a disk
  #   cache is used, and all cached files will use this directory as the root directory.
  #   If anything other than a string is provided, it should respond to []=, which will
  #   be called with a path string and a body value (the 3rd element of the response).
  # * &block : If provided, it is called with the environment and the response from the next middleware.
  #   It should return nil or false if the path should not be cached, and should return
  #   the pathname to use as a string if the result should be cached.
  #   If not provided, the DEFAULT_PATH_PROC is used.
  def initialize(app, cache, &block)
    @app = app
    @cache = cache.sub(/\/*$/, "/") # normalize path to have a single trailing slash.
  end

  def call(env)
    res = @app.call(env)
    page_cache(env, res)
    res
  end
  
  def page_cache(env, res)
    # If the request was successful (response status 200), was a GET request, and
    # had an empty query string, this request is probably cacheable.
    return res unless env['REQUEST_METHOD'] == 'GET' and res[0] == 200 and env['QUERY_STRING'] == ""
    
    # But the content_type, that can be derived from the request path - and is what
    # the web server would use in the next request - must match the content type
    # in the response.
    return unless matching_content_type?(env, res)

    # Build path for cache file. The path must not contain '..', to prevent directory
    # traversal attacks.
    path = env['PATH_INFO']
    return if path.include?('..')
    
    # We cannot use File.join here, because this would eat the double slashes in the path_info.
    # The @cache instance variable, however, is normalized to end in a single slash.
    path = "#{@cache}/#{path}" 
    
    # If the cache file exists already, then we run inside rackup. 
    # The cached file will be delivered by Rack::Static, and we don't need
    # (and don't want to: this zeroes the file, for some reason) to rewrite the path
    return if File.exists?(path)
    
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'wb') do |f| 
      res[2].each do |c| 
        f.write(c)
      end
    end
  end

  def matching_content_type?(env, res)
    return unless content_type = res[1]['Content-Type']
    
    path_info = env['PATH_INFO']
    mime_types = MIME::Types.type_for(path_info)
    mime_types = [ "text/html" ] if mime_types.empty?

    mime_types.any? do |mime_type|
      content_type.index(mime_type)
    end
  end 
end
