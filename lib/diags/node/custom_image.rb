module Diags
  module Node
    class CustomImage < Diags::Node::Base
      
      attr_reader :state
      
      def initialize(image,script)
        @image = image
        @script = script
        @state = calculate_state
      end

      def build(destination_directory='/tmp/martin')
        image = @image.build
      end

      private 

      def calculate_state
        hash = self.class.to_s
        hash << @image.state
        hash << Digest::MD5.hexdigest(@script)
        Digest::MD5.hexdigest hash
      end
    end
  end
end
