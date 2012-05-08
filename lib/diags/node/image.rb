module Diags
  module Node
    class Image < Diags::Node::Base
      @@mirror = 'http://127.0.0.1:3142/ubuntu'
      
      # TODO: needs a way to specify cache type
      
      def initialize(release='precise',packages=nil)
#        super
        @release = release
        @packages = packages
      end

      def go(destination_directory=random_ramfs)
        if Cache::Directory.has_state?(state)
          Cache::Directory.restore_state(state,destination_directory)
        else
          build(destination_directory)
        end
        destination_directory
      end

      def rebuild(destination_directory=random_ramfs)
        build(destination_directory)
      end

      def state
        hash = ''
#        hash = super + "\n"
        hash << @release
        hash << @packages.join(',')
        hash << "\n"
        Digest::MD5.hexdigest(hash)
      end

      private 

      def build(destination_directory)
        logger.info "building image..."
        
        # get a random ramdisk
        dir = Diags::Utils::random_ramfs
        puts "random dir is " + dir

        # generate package list
        include_option = ''
        unless @packages.nil?
          include_option << ' --include=' + @packages.join(',')
        end

        # create image with debootstrap 
        run "time sudo debootstrap #{include_option} #{@release} #{destination_directory} http://127.0.0.1:3142/ubuntu "
        
        # cache
        Cache::Directory.save_state(state,destination_directory)
        
      end

    end
  end
end
