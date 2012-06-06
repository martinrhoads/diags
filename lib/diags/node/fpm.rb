module Diags
  module Node
    class FPM < Diags::Node::Base
      attr_accessor :state
      
      def initialize(opts={})
        @package_dependency = opts['package_dependency']
        @name = opts['name']
        @version = opts['version']
        @apt_dependencies = opts['apt_dependencies']
        @arch = opts['arch']
        @arch ||= `uname -i`.chomp
        @config_files = opts['config_files']
        @post_install = opts['post_install']
        @state = calculate_state
        @destination_file = opts[:destination_file]
        @destination_file ||= "/tmp/fpm/#{@name}-#{@version}-#{@arch}.deb"
      end

      def go()
        if Cache::File.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
          Cache::File.restore_state(@state,@destination_file)
        else
          # build
          build_dir = @package_dependency.go
          dirs_to_copy = Dir.glob(File.join(build_dir,'*'))
          post_install_file = random_file

          File.delete(@destination_file) if File.exists?(@destination_file)
          
          fpm_command = "fpm -s dir -t deb "
          fpm_command << " -n #{@name} "
          fpm_command << " -v #{@version} "
          fpm_command << " -C #{build_dir} "
          @apt_dependencies.each do |apt_dependency|
            fpm_command << " -d #{apt_dependency} "
          end
          fpm_command << " -p #{@destination_file} "
          fpm_command << " --config-files #{@config_files} " if defined? @config_files 
          if defined? @post_install
            File.open(post_install_file, 'w') {|f| f.write(@post_install) }
            fpm_command << " --post-install #{post_install_file} "
          end
          dirs_to_copy.each do |dir_path|
            fpm_command << ' ' << File.basename(dir_path)
          end
          
          FileUtils.mkdir_p File.dirname(@destination_file)
          run fpm_command
          Cache::File.save_state(@destination_file,@state)
#        ensure
          File.delete post_install_file if File.exists? post_install_file
        end
        Diags::Cache::File.path(@state)
      end

      
      protected
      
      def calculate_state()
        hash = self.class.to_s
        hash << @package_dependency.state
        hash << @name
        hash << @version
        hash << @apt_dependencies.to_s
        hash << @arch
        hash << @config_files
        hash << @post_install unless @post_install.nil? 
        Digest::MD5.hexdigest hash
      end
    end
  end
end
