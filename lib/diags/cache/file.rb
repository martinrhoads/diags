module Diags
  module Cache
    class File < Diags::Cache::Base
      CACHE_DIR = ::File.join(Diags::CACHE_DIR,'files')
      
      def initialize()
        super
      end

      def self.save_state(source_path)
        raise "FileDoesNotExist #{source_path}" unless ::File.exists? source_path
        raise "CouldNotMD5File" unless md5 = Digest::MD5.hexdigest(::File.read source_path)
        destination_dir = ::File.join(CACHE_DIR, md5[0,2])
        raise "Could not create directory #{destination_dir}" unless ::File.exists?(destination_dir) || ::FileUtils.mkdir_p(destination_dir)
        destination_path = ::File.join(destination_dir,md5)
        begin
          FileUtils.cp(source_path,destination_path)
        rescue Errno::ENOENT => e
          STDERR.puts "could not copy #{source_path} to #{destination_path}"
          STDERR.puts e.inspect
          raise e
        end
        
      end      
    end
  end
end

