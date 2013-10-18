desc "Run all test with code coverage"
task :coverage do
  system "bundle exec ruby tests/coverage.rb" 
end
   
task :default => :coverage

namespace :cache do
  # remove old entries from cache
  task :clean do
    def public_size_kbyte
      `du -ks public`.to_i
    end
    
    while public_size_kbyte > 1_000_000
      # delete the 100 oldest files
      files_w_mtime = Dir.glob("public/**/*").inject([]) do |ary, file|
        ary << [ file, File.mtime(file) ] if File.file?(file)
        ary
      end.sort_by(&:last).reverse

      files_w_mtime[0...100].each do |file, mtime|
        File.unlink file
      end
    
      # prune empty dirs
      while true
        break if `find public -type d -empty -exec rmdir {} + -print`.empty?
      end 
    end
  end
end
