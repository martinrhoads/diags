module Diags
  module Node
    class Repo < Diags::Node::Base
      
      def initialize(origin,sha1)
#        super
        @origin = origin
        @sha1 = sha1
      end

      def hash
        @sha1
      end

    end
  end
end

