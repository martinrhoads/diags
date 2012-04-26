module Diags
  module Cache
    class Directory < Diags::Cache::Base
      CACHE_DIR = ::File.join(Diags::CACHE_DIR,'git')
      
      def initialize()
        super
      end

      def self.save_state(state,source_directory)
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{source_directory} add . "
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{source_directory} commit -am 'some commit message'"
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{source_directory} tag #{state}"
      end      

      def self.has_state?(state)
        system "sudo git --git-dir=#{CACHE_DIR} tag | grep -q #{state}"
      end

      def self.restore_state(state,destination_directory)
        run "mkdir -p #{destination_directory}"
        run "git --git-dir=#{CACHE_DIR} --work-tree=#{destination_directory} clean -fd" 
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{destination_directory} reset --hard #{state}"
      end
    end
  end
end

