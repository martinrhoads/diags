module Diags
  module Node
    class Server < Diags::Node::Base
      @@mirror = 'http://127.0.0.1:3142/ubuntu'
      
      
      def initialize(release='precise',packages=nil)
      end

      def go(destination_directory=random_ramfs)
      end

      def rebuild(destination_directory=random_ramfs)
      end

      def state
      end

      private 

      def build(destination_directory)
      end

    end
  end
end
