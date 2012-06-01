module Diags
  module Cache
    class Directory < Diags::Cache::Base
      CACHE_DIR = ::File.join(Diags::CACHE_DIR,'git')
      
      def initialize()
        unless Dir.exists? CACHE_DIR
          run("git --git-dir=#{CACHE_DIR} init --bare")
        end
      end

      def self.save_state(state,source_directory)
        logger.info "saving directory state..."
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{source_directory} add . "
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{source_directory} commit -am '#{state}'"
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{source_directory} tag --force #{state}"
      end      

      def self.has_state?(state)
        system "sudo git --git-dir=#{CACHE_DIR} tag | grep -q #{state}"
      end

      def self.restore_state(state,destination_directory)
        run "mkdir -p #{destination_directory}"
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{destination_directory} clean -fd" 
        run "sudo git --git-dir=#{CACHE_DIR} --work-tree=#{destination_directory} reset --hard #{state}"
      end
    end
  end
end

