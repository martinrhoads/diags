module Diags
  module Node
    class Image < Diags::Node::Base
      @@mirror = 'http://127.0.0.1:3142/ubuntu'
      
      # TODO: needs a way to specify cache type
      
      def initialize(release='precise')
        super
        @release = release
      end

      def build(destination_directory=Diags::Utils::random_dir)
        if Cache::Directory.has_state?(state)
          Cache::Directory.restore_state(state,destination_directory)
        else
          private_build(destination_directory)
        end
        destination_directory
      end

      def rebuild(destination_directory='/tmp/martin')
        private_build(destination_directory)
      end

      def state
        hash = super + "\n"
        hash << @release
        hash << "\n"
        Digest::MD5.hexdigest(hash)
      end

      private 

      def private_build(destination_directory='/tmp/martin')
        puts "building image..."
        
        # get a random ramdisk
        dir = Diags::Utils::random_ramfs
        puts "random dir is " + dir
        
        # create image with debootstrap 
        run "time sudo debootstrap #{@release} #{dir} http://127.0.0.1:3142/ubuntu"
        
        # cache
        Cache::Directory.save_state(state,dir)
        
        # set state
        run "mkdir -p #{destination_directory}"
        run "rsync -a --delete #{dir}/ #{destination_directory}/"

        # clean up 
        Diags::Utils::unmount(dir)
      end

    end
  end
end
