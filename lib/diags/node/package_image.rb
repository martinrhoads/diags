module Diags
  module Node
    class PackageImage < Diags::Node::Base
      
      attr_reader :state
      
      def initialize(image,destination_file=random_file)
        @image = image
        @state = calculate_state
        @destination_file = destination_file
        @disk_size = 3
      end

      def go
        if Cache::File.has_state?(state)
          Cache::File.restore_state(state,@destination_file)
        else
          @image.go
          build
        end
        @destination_file
      end

      private 

      def calculate_state
        hash = self.class.to_s
        hash << @image.state
        Digest::MD5.hexdigest hash
      end

      def build
        mount_directory = random_dir
        fstab_tmp_file = random_file
        raw_image = File.join(random_ramfs,'image')
        logger.info "attempting to mount devices on #{@raw_image} for chroot..."

        begin

          # do image build stuff 
          run "sudo qemu-img create -f raw #{raw_image} #{@disk_size}G"
          run "echo '1,+,,*' | sudo sfdisk #{raw_image}"
          fstab = <<eof
proc    /proc   proc    nodev,noexec,nosuid     0       0
/dev/sda1       /       xfs     defaults,noatime        0       2
eof

          loopback_device = run "sudo kpartx -av #{raw_image} |cut -f 3 -d ' '"
          raise "could not find loopback device " if loopback_device.empty?
          short_loopback_device = loopback_device.gsub(/p1$/,'')
          logger.debug "kpartx reported mapping device: #{loopback_device}"
          run "sudo mkfs.xfs -f /dev/mapper/#{loopback_device}"
          run "sudo mount /dev/mapper/#{loopback_device} #{mount_directory}"
          logger.debug "copying image into place"
          run "sudo cp -a #{@image.destination_directory}/* #{mount_directory}/."
          run "sudo sed -i 's%GRUB_CMDLINE_LINUX_DEFAULT=.*%GRUB_CMDLINE_LINUX_DEFAULT=\"nosplash nomodeset text INIT_VERBOSE=yes init=/sbin/init -v noplymouth\"%' #{mount_directory}/etc/default/grub"
          make_chrootable(mount_directory)
          run "sudo chroot #{mount_directory} grub-mkconfig -o /boot/grub/grub.cfg"
          run "sudo chroot #{mount_directory} grub-install --force /dev/short_loopback_device"
          run "sudo sed -i 's%/dev/#{short_loopback_device}%/dev/sda%' #{mount_directory}/boot/grub/grub.cfg" 
          run "sudo sed -i 's%/dev/mapper/#{short_loopback_device}%/dev/sda1%' #{mount_directory}/boot/grub/grub.cfg"
          fstab_tmp = random_file
          File.open(fstab_tmp, 'w') {|f| f.write(fstab) }
          run "sudo mv #{fstab_tmp} #{File.join(mount_directory,'etc','fstab')}"
          run "sudo sync"
          undo_make_chrootable
          run "sudo umount -lf #{mount_directory}"
          run "sudo kpartx -dv #{mount_directory}"
          run "sudo sync"
          logger.debug "exporting image to qcow2"
          run "qemu-img convert -f raw -O qcow2 #{raw_image} #{@destination_file}"
          run "sudo rm -rf #{raw_image}"
          logger.debug "finished converting image to qcow1"

        ensure
          undo_make_chrootable(mount_directory)
          logger.info "in ensure clause"
        end

        logger.info "caching image..."
        Cache::File.save_state(@state,@destination_file)
        
        logger.info "done packaging image"
      end
    end
  end
end
