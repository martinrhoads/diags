module Diags
  module Node
    class ImageSeed < Diags::Node::Image
      
      attr_reader :state
      
      def initialize(opts={})
        @image = opts[:image]
        @script = opts[:script]
        @state = calculate_state
      end

      def go(destination_directory=random_ramfs)
        if Cache::Directory.has_state?(@state)
          Cache::Directory.restore_state(@state,destination_directory)
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

      def insert_upstart_file(destination_directory)
        upstart_file = <<EOF
description     "seed script for diags"
author          "diags"

start on (local-filesystems and net-device-up IFACE=eth0)

script

/root/diags.sh > /root/diags.log
echo "exit status was $?" >> /root/diags.log

init 0

end script

EOF
        upstart_file_path = File.join(destination_directory,'etc/init/diags.conf')
        File.open(upstart_file_path, 'w') {|f| f.write(upstart_file) }
      end

      def insert_seed(destination_directory)
        seed_file = File.join(destination_directory,'root/diags.sh')
        File.open(seed_file, 'w') {|f| f.write(@script) }
        File.chmod(0755, seed_file)
      end



      def build(destination_directory)
        logger.info "seeding image"
        insert_upstart_file(destination_directory)
        insert_seed(destination_directory)
        logger.info "caching image customization..."
        Cache::Directory.save_state(@state,image_dir)
        logger.info "done seeding image"
      end
    end
  end
end
