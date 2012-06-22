 module Diags
  module Node
    class PackageDir < Diags::Node::Base
      
      def initialize(opts={})
        @repo = opts['repo']
        @build_command = opts['build_command']
        @build_artifact = opts['build_artifact']
        @state = calculate_state
      end

      def go()
        if Diags::Cache::Directory.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
          Diags::Cache::Directory.restore_state(@state,@destination_file)
        else
          # build
          repo_dir = @repo.go
          destination_dir = random_ramfs
          ENV['DIAGS_DESTINATION_DIR'] =  destination_dir
          ENV['GIT_DIR'] = GIT_CACHE_DIR
          ENV['GIT_WORK_TREE'] = repo_dir
          run(@build_command,repo_dir)
          
          Diags::Cache::Directory.save_state(@state,destination_dir)
        end
        Diags::Cache::Directory.restore_state(@state,random_ramfs)
      end
      
      def set_state(destination=random_ramfs)
        my_set_state(@state,destination)
      end
    
      def self.set_state(state,destination)
        my_set_state(state,destination)
      end
      
      protected

      def my_set_state(state,destination)
        go unless Diags::Cache::Directory.has_state?(state)
        Diags::Cache::Directory.restore_state(state,destination)
        destination
      end

      
      def calculate_state()
        hash = self.class.to_s
        hash << @repo.state
        hash << @build_command
        Digest::MD5.hexdigest hash
      end
      
      
    end
  end
end
