Bundler.require(:default, :test)

require "#{File.expand_path File.dirname(__FILE__)}/../app.rb"
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class ImgioTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hello_world
    get '/'
    assert last_response.ok?
    assert_equal 'Hello, world!', last_response.body
  end

  def test_it_fills_100_50
    get '/fill/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    img = ImageSize.new(last_response.body)
    assert_equal 100, img.width
    assert_equal 50, img.height
  end

  def test_it_fits_100_50
    get '/fill/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    img = ImageSize.new(last_response.body)
    assert_equal 100, img.width or assert_equal 50, img.height
  end

  def test_it_returns_jpg
    get '/fill/jpg/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    img = ImageSize.new(last_response.body)
    assert_equal :jpeg, img.format
  end

  def test_it_returns_png
    get '/fill/png/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    img = ImageSize.new(last_response.body)
    assert_equal :png, img.format
  end
end