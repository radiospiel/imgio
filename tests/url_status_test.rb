require_relative "test_helper"

class UrlStatusTest < ImgioTestCase
  attr :headers, :status

  def run_assembly(path)
    assembly_line = AssemblyLine.new(path)
    @status, @headers, body = assembly_line.run
    body
  end
  
  def test_get_404
    run_assembly '/fill/100x50/http://www.rubycgi.org/image/missing.jpg'
    assert_equal(status, 404)
  end
end
