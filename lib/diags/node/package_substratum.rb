module Diags
  module Node
    class PackageSubstratum < Diags::Node::Base

      attr_reader :state

      def initialize(config={})
        # TODO: verify proper params? 
        @config = config

        # create dependency objects
        @config['dependency_packages'].each do |package,package_params| 
          package_params['repo'] = Diags::Node::Git.new package_params
          package_object = Diags::Node::Package.new package_params
          package_params['package_object'] = package_object
        end

        @substratum_repo_object = Diags::Node::Git.new @config

        @state = calculate_state
      end
      
      def set_state()
        destination_dir = random_ramfs
        if Cache::Directory.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
          Diags::Cache::Directory.restore_state(@state,destination_dir)
        else
          logger.debug "building #{self.class}"
          
          substratum_build_workspace = @substratum_repo_object.set_state
          
          # build and insert dependency packages
          FileUtils.mkdir_p(File.join(substratum_build_workspace,"/vendor/cache/"))
          @config['dependency_packages'].each do |package_name,package_options| 
            destination_path = File.join(substratum_build_workspace,"/vendor/cache/#{package_name}.gem")
            package_options['package_object'].set_state destination_path
          end
          
          run("DIAGS_DESTINATION_DIR=#{destination_dir} GIT_DIR=#{GIT_CACHE_DIR} GIT_WORK_TREE=#{substratum_build_workspace} #{@config['build_command']}",substratum_build_workspace)
          
          FileUtils.mkdir_p File.join(destination_dir,'srv/substratum/services')
          stuff_to_copy = Dir.glob File.join(substratum_build_workspace,'*')
          Dir.glob(File.join(substratum_build_workspace,'.??*')).each do |hidden_file|
            stuff_to_copy << hidden_file
          end
          stuff_to_copy.delete(File.join(substratum_build_workspace,'logs')) if stuff_to_copy.include?(File.join(substratum_build_workspace,'logs'))
          stuff_to_copy.each do |thing_to_copy|
            where_to_put_thing = File.join(destination_dir,'srv/substratum/services',File.basename(thing_to_copy))
            FileUtils.cp_r(thing_to_copy,where_to_put_thing)
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
          FileUtils.cp_r(File.join(substratum_build_workspace,'/etc'),destination_dir)
          FileUtils.cp(File.join(substratum_build_workspace,'examples/config.json'),File.join(destination_dir,'etc/substratum/config.json.example'))
          FileUtils.ln_s('/srv/substratum/services/bin/substratum',File.join(destination_dir,'/usr/bin/substratum'))
          FileUtils.ln_s('/var/log/substratum/',File.join(destination_dir,'/srv/substratum/services/logs'))
          
          Diags::Cache::Directory.save_state(@state,destination_dir)
        end
        return destination_dir
      end

      
      protected
      
      def calculate_state()
        hash = self.class.to_s
           hash << @config['build_command']
        hash << @substratum_repo_object.state
        @config['dependency_packages'].each do |package,package_params| 
          hash << package_params['package_object'].state
        end
        Digest::MD5.hexdigest hash
      end
      
    end
  end

end
