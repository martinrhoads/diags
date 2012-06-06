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
        destination_dir = random_ramfs
        if Cache::Directory.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
          Diags::Cache::Directory.restore_state(@state,destination_dir)
        else
          logger.debug "building #{self.class}"
          repo_dir = @repo.go

          # insert dependency packages
          FileUtils.mkdir_p(File.join(repo_dir,"/vendor/cache/"))
          @dependencies.each do |repo,package|
            destination_path = File.join(repo_dir,"/vendor/cache/#{repo}.gem")
            package.restore_state(destination_path)
          end

          run("DIAGS_DESTINATION_DIR=#{destination_dir} GIT_DIR=#{GIT_CACHE_DIR} GIT_WORK_TREE=#{repo_dir} #{@build_command}",repo_dir)

          FileUtils.mkdir_p File.join(destination_dir,'srv/substratum/services')
          stuff_to_copy = Dir.glob File.join(repo_dir,'*')
          Dir.glob(File.join(repo_dir,'.??*')).each do |hidden_file|
            stuff_to_copy << hidden_file
          end
          stuff_to_copy.delete(File.join(repo_dir,'logs')) if stuff_to_copy.include?(File.join(repo_dir,'logs'))
          stuff_to_copy.each do |thing|
            FileUtils.cp_r(thing,File.join(destination_dir,'srv/substratum/services',File.basename(thing)))
          end

          [
           "/etc/default",
           "/etc/init",
           "/etc/logrotate.d",
           "/etc/substratum",
           "/usr/bin",
           "/var/log/substratum",
           "/var/run/substratum",
           "/var/tmp/substratum",
          ].each do |dir|
            FileUtils.mkdir_p File.join(destination_dir,dir)
          end

          # copy in files and create links
          FileUtils.cp_r(File.join(repo_dir,'/etc'),destination_dir)
          FileUtils.cp(File.join(repo_dir,'examples/config.json'),File.join(destination_dir,'etc/substratum/config.json.example'))
          FileUtils.ln_s('/srv/substratum/services/bin/substratum',File.join(destination_dir,'/usr/bin/substratum'))
          FileUtils.ln_s('/var/log/substratum/',File.join(destination_dir,'/srv/substratum/services/logs'))
          
          Diags::Cache::Directory.save_state(@state,destination_dir)
        end
        return destination_dir
      end

      
      protected
      
      def calculate_state()
        hash = self.class.to_s
        hash << @repo.state
        hash << @build_command
        hash << @build_artifact
        @dependencies.each_value do |package|
          hash << package.state
        end if @dependencies
        Digest::MD5.hexdigest hash
      end
      
      
    end
  end
end
