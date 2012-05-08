module Diags
  module Node
    class CustomImage < Diags::Node::Base
      
      attr_reader :state
      
      def initialize(image,script)
        @image = image
        @script = script
        @state = calculate_state
      end

      def go(destination_directory=random_ramfs)
        if Cache::Directory.has_state?(state)
          Cache::Directory.restore_state(state,destination_directory)
        else
          @image.go(destination_directory)
          build(destination_directory)
        end
        destination_directory
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
          run "sudo mkdir -p #{image_dir}/proc #{image_dir}/dev #{image_dir}/sys #{image_dir}/tmp #{image_dir}/dev/pts"
          run "sudo mount -t proc none #{image_dir}/proc"
          run "sudo mount --bind /dev #{image_dir}/dev"
          run "sudo mount sysfs -t sysfs #{image_dir}/sys"
          run "sudo mount -t devpts none #{image_dir}/dev/pts"
          logger.info "mounting successful "


          tmp_file = random_file
          chroot_script = File.join(image_dir,'tmp','script')
          File.open(tmp_file, 'w') {|f| f.write(@script) }
          run "sudo cp /etc/mtab #{File.join(image_dir,'/etc/mtab')}"
          run "sudo mv #{tmp_file} #{chroot_script} && sudo chmod +x #{chroot_script}"
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
