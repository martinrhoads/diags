 module Diags
  module Node
    class Package < Diags::Node::Base
      
      def initialize(opts={})
        @repo = opts['repo']
        @build_command = opts['build_command']
        @destination_file = opts['destination_file']
        @destination_file ||= random_file
        @build_artifact = opts['build_artifact']
        @state = calculate_state
      end

      def go()
        if Cache::File.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
          Cache::File.restore_state(@state,@destination_file)
        else
          # build
          repo_dir = @repo.go
          destination_dir = random_ramfs
          begin
            run("DIAGS_DESTINATION_DIR=#{destination_dir} GIT_DIR=#{GIT_CACHE_DIR} GIT_WORK_TREE=#{repo_dir} #{@build_command}",repo_dir)
          ensure
            # TODO: clean shit up 
#            FileUtils.rm_rf repo_dir
          end

          file_matches = Dir.glob(File.join(repo_dir,@build_artifact))
          raise "found #{file_matches.size} file matches instead of 1" unless file_matches.size == 1
          package_file = file_matches.first
          Cache::File.save_state(package_file,@state)
          package_file
        end
        artifact_file = Diags::Cache::File.path(@state)
        artifact_file
      end
      
      def set_state(destination)
        my_set_state(@state,destination)
      end
    
      def self.set_state(state,destination)
        my_set_state(state,destination)
      end
      
      protected

      def my_set_state(state,destination)
        go unless Cache::File.has_state?(state)
        Cache::File.restore_state(state,destination)
      end

      
      def calculate_state()
        hash = self.class.to_s
        hash << @repo.state
        hash << @build_command
        hash << @build_artifact
        Digest::MD5.hexdigest hash
      end
      
      
    end
  end
end
