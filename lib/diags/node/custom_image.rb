module Diags
  module Node
    class CustomImage < Diags::Node::Base
      
      attr_reader :state, :destination_directory
      
      def initialize(image,script,destination_directory=random_ramfs)
        @image = image
        @script = script
        @state = calculate_state
        @destination_directory = destination_directory
      end

      def go
        if Cache::Directory.has_state?(@state)
          Cache::Directory.restore_state(@state,@destination_directory)
        else
          @image.go(@destination_directory)
          build(@destination_directory)
        end
        @destination_directory
      end

      private 

      def calculate_state
        hash = self.class.to_s
        hash << @image.state
        hash << Digest::MD5.hexdigest(@script)
        Digest::MD5.hexdigest hash
      end

      def build(image_dir)
        logger.info "attempting to mount devices on #{image_dir} for chroot..."
        begin
          make_chrootable(image_dir)
          logger.info "mounting successful "


          tmp_file = random_file
          chroot_script = File.join(image_dir,'tmp','script')
          File.open(tmp_file, 'w') {|f| f.write(@script) }
          run "sudo cp /etc/mtab #{File.join(image_dir,'/etc/mtab')}"
          run "sudo mkdir #{File.join(image_dir,'tmp')}"
          run "sudo mv #{tmp_file} #{chroot_script} && sudo chmod +x #{chroot_script}"
          logger.debug "about to chroot into image at: #{image_dir}"
          run "sudo chroot #{image_dir} ./tmp/script"
          run "sudo rm #{chroot_script}"

        ensure
          logger.info "cleaning up mounts"
          unmount "#{image_dir}/proc"
          unmount "#{image_dir}/dev/pts"
          unmount "#{image_dir}/dev"
          unmount "#{image_dir}/sys"
        end

        logger.info "caching image customization..."
        Cache::Directory.save_state(@state,image_dir)
        
        logger.info "done customizing image"
      end
    end
  end
end
