module Diags
  module Node
    class PackageSubstratum < Diags::Node::Base
      
      def initialize(opts={})
        @files = opts['files']
        @repo = opts['repo']
        @build_command = opts['build_command']
        @destination_file = opts['destination_file']
        @build_artifact = opts['build_artifact']
        @state = calculate_state
        @post_install = opts['post_install']
        @name = opts['name']
        @version = opts['version']
        @dependencies = opts['dependencies']
      end

      def go()
        if Cache::File.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
          Cache::File.restore_state(@state,@destination_file)
        else
          # build
          repo_dir = @repo.go
          destination_dir = random_ramfs

          # insert dependency packages
          FileUtils.mkdir_p(File.join(repo_dir,"/vendor/cache/"))
          @dependencies.each do |repo,package|
            destination_path = File.join(repo_dir,"/vendor/cache/#{repo}.gem")
            package.restore_state(destination_path)
          end

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
        Diags::Cache::File.path(@state)
      end

      
      protected
      
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