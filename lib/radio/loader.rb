#
# A Path foo/bar/baz is handled by the FooBarBazController, the FooBarController, or the BarController.
# As a preparation we load the radio/foo/bar/baz.rb, radio/foo/bar.rb, and radio/foo.rb files first.
class Radio::Loader
  def self.load_class(name)
    const_get(name)
  rescue NameError
  end

  module Development
    def load_file(name)
      fullname = "#{ROOT}/radio/#{name}.rb"
      puts "loading: #{fullname}"
      load fullname
    rescue LoadError
    end

    def setup
    end

    def controller_class_for(path)
      loader = PathLoader.new(path)
      loader.load_files
      loader.load_class || load_root_controller
    end
  end
  
  module Production
    def load_file(name); end
    
    def setup
      Dir.glob("#{ROOT}/radio/**/*.rb").sort.each do |file|
        puts "loading: #{ROOT}/radio/#{name}.rb"
        load file
      end
    end

    def controller_class_for(path)
      loader = PathLoader.new(path)
      loader.load_class || load_root_controller
    end
  end
  
  if Radio.development?
    extend Development
  else
    extend Production
  end
  
  def self.load_root_controller
    load_file("root")
    load_class("RootController")
  end

  # -- A loader object is used to load the class for a specific path.

  class PathLoader
    def initialize(path)
      @path = path
    end

    def load_class
      p = parts.map { |part| part[0,1].upcase + part[1..-1] }
      while p.length > 0 do
        klass = Radio::Loader.load_class parts.join("") + "Controller"
        return klass if klass
        p.pop
      end
      nil
    end

    def load_files
      p = parts
      while p.length > 0 do
        Radio::Loader.load_file p.join("/")
        p.pop
      end
    end

    private

    def parts
      @path.split(/\//).map do |part| 
        next unless part =~ /^([a-zA-Z_])([a-zA-Z_0-9]*)$/
        part.downcase
      end.compact
    end
  end
end
