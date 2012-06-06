module Diags
  module Node
    class Package < Diags::Node::Base
      
      def initialize(opts={})
        @repo = opts[:repo]
        @script_template = opts[:script_template] 
        @destination_file = opts[:destination_file]
        @state = calculate_state
        @post_install = opts[:post_install]
        @name = opts[:name]
        @version = opts[:version]
      end

      def parse_template(opts={})
        @generated_template = ERB.new(@script_template).result(binding) unless defined? @generated_template
        @generated_template
      end

      def go()
        if Cache::File.has_state?(@state)
          logger.debug "found previous state for #{self.class}"
          Cache::File.restore_state(@state,@destination_file)
        else
          # build
          repo_dir = @repo.go
          destination_dir = random_ramfs
          opts = {}
          opts[:destination_dir] = destination_dir
          parse_template(opts) 
          Dir.chdir repo_dir
          File.open('build_script', 'w') {|f| f.write(@generated_template) }
          begin
            run "bash build_script"
          ensure
            # TODO: clean shit up 
#            FileUtils.rm_rf repo_dir
          end

          deb_file = random_file
          File.delete deb_file
          fpm_command =  "fpm -s dir -t deb -n #{@name} -v #{@version} -C #{destination_dir} -p #{deb_file}  "
          if defined? @post_install
            post_install_file = random_file
            File.open(post_install_file, 'w') {|f| f.write(@post_install) }
            fpm_command << " --post-install #{post_install_file} "
          end
          fpm_command << " . "

          run fpm_command
          File.delete post_install_file if defined? post_install_file
          Cache::File.save_state(deb_file,@state)
        end
        Diags::Cache::File.path(@state)
      end

      
      protected
      
      def calculate_state()
        hash = self.class.to_s
        hash << @repo.state
        hash << Digest::MD5.hexdigest(@script_template)
        Digest::MD5.hexdigest hash
      end
      
      
    end
  end
end
