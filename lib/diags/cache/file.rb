module Diags
  module Cache
    class File < Diags::Cache::Base
      CACHE_DIR = ::File.join(Diags::CACHE_DIR,'files')
      
      def initialize()
      end

      def self.has_state?(state)
        return false unless ::File.exists?(path(state))
        return true if state == Digest::MD5.hexdigest(::File.read(path state))
        logger.debug "removing incorrect state file #{state}"
        ::File.delete(path state)
        false
      end

      def self.restore_state(state,destination_file)
        raise "can not find state" unless self.has_state?(state)
        FileUtils.cp(path state,destination_file)
      end

      def self.save_state(source_path)
        raise "FileDoesNotExist #{source_path}" unless ::File.exists? source_path
        raise "CouldNotMD5File" unless md5 = Digest::MD5.hexdigest(::File.read source_path)
        raise "Could not create directory #{destination_dir}" unless ::File.exists?(destination_dir) || ::FileUtils.mkdir_p(destination_dir)
        destination_path = path(md5)
        begin
          FileUtils.cp(source_path,destination_path)
        rescue Errno::ENOENT => e
          STDERR.puts "could not copy #{source_path} to #{destination_path}"
          STDERR.puts e.inspect
          raise e
        end
        
      end      
      
      protected

      def self.path(md5)
        destination_dir = ::File.join(CACHE_DIR, md5[0,2],md5)
      end
    end
  end
end

