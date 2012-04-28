require_relative "test_helper"

#
# Test the "controller" method: is a Rack request properly wired
# to the Assembly Line?
class FunctionalTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    VCR.insert_cassette('imgio')
  end
  
  def teardown
    VCR.eject_cassette
  end

  def app
    Sinatra::Application
  end

  def test_be_nice_to_your_users
    get '/'
    assert last_response.ok?
    assert_match %r{Welcome to imgio}, last_response.body
  end

  def test_with_workflow_path
    url = '/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    
    mock = {}
    
    AssemblyLine.expects(:new).with(url).returns(mock)
    mock.expects(:run).returns [200, { "header" => "value"}, "42"]

    get url

    assert_equal "public, max-age=86400", last_response.headers['Cache-Control']
    assert_not_nil last_response.headers['Expires']
  end

  def test_conversion_to_jpg
    get '/jpg/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 'image/jpg', last_response.headers['Content-Type']
  end

  def test_conversion_to_png
    get '/png/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 'image/png', last_response.headers['Content-Type']
  end

  def test_automatic_conversion_to_png
    get '/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 'image/png', last_response.headers['Content-Type']
  end
end
