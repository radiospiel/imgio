source :rubygems

gem "sinatra-synchrony"
gem "rmagick"
gem "thin"
gem "sinatra-contrib", :group => :development

group :test do
  gem "rack-test", :require => 'rack/test'
  gem "image_size"
  gem "ruby-debug19"
  
  # vcr stuff: this needs psych or else will crash
  gem "vcr"
  gem "webmock"
  gem "psych"
end
