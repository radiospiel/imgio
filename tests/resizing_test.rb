require_relative "test_helper"

class ResizingTest < ImgioTestCase
  attr :headers, :image

  def run_assembly(path)
    assembly_line = AssemblyLine.new(path)
    @status, @headers, body = assembly_line.run
    body
  end
  
  def test_raise_exception_on_invalid_request
    assert_raise(RuntimeError) {  
      # The request path's format is invalid.
      run_assembly '/fill/100/50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    }
  end
  
  def test_fill_a_rectangle_with_the_image
    image = run_assembly '/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 100, image.columns
    assert_equal 50, image.rows
  end
  
  def test_fit_the_image_into_a_rectangle
    image = run_assembly '/fit/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    assert_equal 100, image.columns
    assert_equal 50, image.rows
  end
  
  def test_conversion_to_jpg
    blob = run_assembly '/jpg/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    image = Magick::Image.from_blob(blob).first
    assert_equal "JPEG", image.format
  end
  
  def test_conversion_to_png
    blob = run_assembly '/jpg/fill/100x50/http://www.rubycgi.org/image/ruby_gtk_book_title.jpg'
    image = Magick::Image.from_blob(blob).first
    assert_equal "JPEG", image.format
  end
end
