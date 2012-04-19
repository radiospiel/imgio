require 'simplecov'

SimpleCov.start do
  add_filter "test/*"
  add_filter "lib/http.rb"
end

SimpleCov.start

Dir.glob("#{File.dirname(__FILE__)}/*_test.rb").each do |file|
  load file
end
