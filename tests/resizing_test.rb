require_relative "test_helper"

class ImgioTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def image
    ImageSize.new(last_response.body)
  end

  def setup
    VCR.insert_cassette('imgio')
  end
  
  def teardown
    VCR.eject_cassette
  end
  
  def test_be_nice_to_your_users
    get '/'
    assert last_response.ok?
    assert_match %r{Welcome to imgio}, last_response.body
  end

  def test_raise_exception_on_invalid_request
    assert_raise(RuntimeError) {  
      get '/fill/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
      assert_equal 100, image.width
      assert_equal 50, image.height
    }
  end
  
  def test_fill_a_rectangle_with_the_image
    get '/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 100, image.width
    assert_equal 50, image.height
  end
  
  def test_fit_the_image_into_a_rectangle
    get '/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 100, image.width
    assert_equal 50, image.height
  end
  
  def test_respond_with_png_by_default
    get '/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal :png, image.format
    assert_equal 'image/png', last_response.headers['Content-Type']
  end
  
  def test_respond_with_jpeg_if_requested
    get '/jpg/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal :jpeg, image.format
    assert_equal 'image/jpg', last_response.headers['Content-Type']
  end

  def test_set_caching_headers
    get '/png/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal "public, max-age=86400", last_response.headers['Cache-Control']
    assert_not_nil last_response.headers['Expires']
  end

end
