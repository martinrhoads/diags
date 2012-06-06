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
        if Cache::Directory.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
        else
          logger.debug "building #{self.class}"
          repo_dir = @repo.go
          destination_dir = random_ramfs

          # insert dependency packages
          FileUtils.mkdir_p(File.join(repo_dir,"/vendor/cache/"))
          @dependencies.each do |repo,package|
            destination_path = File.join(repo_dir,"/vendor/cache/#{repo}.gem")
            package.restore_state(destination_path)
          end

          run("DIAGS_DESTINATION_DIR=#{destination_dir} GIT_DIR=#{GIT_CACHE_DIR} GIT_WORK_TREE=#{repo_dir} #{@build_command}",repo_dir)

          fake_root = random_ramfs
          FileUtils.mkdir_p File.join(fake_root,'srv/substratum/services')
          stuff_to_copy = Dir.glob File.join(repo_dir,'*')
          Dir.glob(File.join(repo_dir,'.??*')).each do |hidden_file|
            stuff_to_copy << hidden_file
          end
          stuff_to_copy.delete(File.join(repo_dir,'logs')) if stuff_to_copy.include?(File.join(repo_dir,'logs'))
          stuff_to_copy.each do |thing|
            STDERR.puts "about to copy #{thing} to #{File.join(fake_root,'srv/substratum/services',File.basename(thing))}"
            FileUtils.cp_r(thing,File.join(fake_root,'srv/substratum/services',File.basename(thing)))
          end

          [
           "/etc/init",
           "/etc/logrotate.d",
           "/var/log/substratum",
           "/var/run/substratum",
           "/var/tmp/substratum",
           "/etc/default",
           "/etc/substratum",
           "/usr/bin",
          ].each do |dir|
            FileUtils.mkdir_p File.join(fake_root,dir)
          end
          
          FileUtils.cp_r(File.join(repo_dir,'/etc'),fake_root)
          FileUtils.cp(File.join(repo_dir,'examples/config.json'),File.join(fake_root,'etc/substratum/config.json.example'))
          FileUtils.ln_s('/srv/substratum/services/bin/substratum',File.join(fake_root,'/usr/bin/substratum'))
          
          Diags::Cache::Directory.save_state(@state,fake_root)
          return fake_root
        end
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
