require "goliath"
require "#{File.dirname(__FILE__)}/config"
require "radio"

class App < Goliath::API
  # parse query params
  use Goliath::Rack::Params
  use Goliath::Rack::Render
 
  def response(env)
    Radio::Request.new(env).process
  end
end
