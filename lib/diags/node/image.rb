module Diags
  module Node
    class Image < Diags::Node::Base
      @@mirror = 'http://127.0.0.1:3142/ubuntu'
      @release = 'precise'

      

      # TODO: needs a way to specify cache type
      
      def initialize()
        super
      end

      def build()
        puts "building image..."
        
        # get a random ramdisk

        # debootstrap 
        output = `#{command}`
        if $?.success?
          puts "built image"
        else
          STDERR.puts "debootstrap failed!!!"
          STDERR.puts "output :"
          STDERR.puts output
          raise "debootstrap failed" 
        end
        
      end

      def hash
        hash = super + "\n"
        hash << "hi there\n"
        hash << command
        hash << "\n"
        return hash
      end

      private 

      def command
        "true #time sudo debootstrap #{@release} /tmp/debootstrap/ http://127.0.0.1:3142/ubuntu"
      end


    end
  end
end
