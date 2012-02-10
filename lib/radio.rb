module Radio
  def self.development?
    true
  end
  
  def self.production?
    !development?
  end
end

require "radio/loader.rb"
require "radio/controller.rb"
require "radio/request.rb"
require "radio/utils.rb"

Radio::Loader.setup
