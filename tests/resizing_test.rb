ENV['RACK_ENV'] = 'test'
Bundler.setup(:default)
require "#{File.dirname(__FILE__)}/../app.rb"
require 'test/unit'
Bundler.require(:test)

Sinatra::Synchrony.patch_tests!

class ImgioTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def image
    ImageSize.new(last_response.body)
  end

  def test_be_nice_to_your_users
    get '/'
    assert last_response.ok?
    assert_match /Welcome to imgio/, last_response.body
  end

  def test_fill_a_rectangle_with_the_image
    get '/fill/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 100, image.width
    assert_equal 50, image.height
  end
  
  def test_fit_the_image_into_a_rectangle
    get '/fill/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 100, image.width
    assert_equal 50, image.height
  end
  
  def test_respond_with_jpg_by_default
    get '/fill/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal :jpeg, image.format
    assert_equal 'image/jpeg', last_response.headers['Content-Type']
  end
  
  def test_respond_with_png_if_requested
    get '/fill/png/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal :png, image.format
    assert_equal 'image/png', last_response.headers['Content-Type']
  end

  def test_set_caching_headers
    get '/fill/png/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal "public, max-age=86400", last_response.headers['Cache-Control']
    assert_not_nil last_response.headers['Expires']
  end

end
