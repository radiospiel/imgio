source 'https://rubygems.org'
ruby "2.0.0"

gem "sinatra-synchrony"
gem "rack_page_cache"
gem "rmagick"
gem "thin"
gem "sinatra-contrib", :group => :development

group :test do
  gem "rack-test", :require => 'rack/test'
  gem "image_size"
  gem "debugger"
  
  # vcr stuff: this needs psych or else will crash
  gem "vcr"
  gem "webmock"
  gem "psych"

  gem "mocha", :require => false
  gem "rake"
  
  gem "simplecov"
end
