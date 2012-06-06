module Diags
  module Cache
    class File < Diags::Cache::Base
      FILE_CACHE_DIR = ::File.join(Diags::CACHE_DIR,'files')
      
      def initialize()
      end

      def self.has_state?(state)
        ::File.exists?(path(state))
      end

      def self.restore_state(state,destination_file)
        raise "can not find state" unless self.has_state?(state)
        FileUtils.cp(path(state),destination_file)
      end

      def self.save_state(source_path,state)
        raise "FileDoesNotExist #{source_path}" unless ::File.exists? source_path
        destination_path = path(state)
        destination_dir = ::File.dirname destination_path
        raise "Could not create directory #{destination_dir}" unless ::File.exists?(destination_dir) || ::FileUtils.mkdir_p(destination_dir)
        begin
          FileUtils.cp(source_path,destination_path)
        rescue Errno::ENOENT => e
          STDERR.puts "could not copy #{source_path} to #{destination_path}"
          STDERR.puts e.inspect
          raise e
        end
        
      end      
      
      def self.path(state)
        destination_dir = ::File.join(FILE_CACHE_DIR, state[0,2],state)
      end

      protected

    end
  end
end

