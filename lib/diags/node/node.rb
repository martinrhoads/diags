module Diags
  module Node
    class Base
      def initialize(opts={})
      end
      
      def build()
        raise "not implmented"
      end
      
      def clean()
        raise "not implmented"
      end
      
      def cache()
        raise "not implmented"
      end
      
      def reset()
        raise "not implmented"
    end
      
    end
  end
end
