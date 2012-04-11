module Diags
  module Node
    class Base

      def initialize(opts={})
        @parents=[]
        @artifacts=[]
        @hash=nil
      end
      
      def hash
        if @hash.nil?
          hash=''
          hash << self.class.name
          @parents.each {|parent| hash << parent.hash }
          @hash=hash
        end
        return @hash
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

      protected

      def my_hash
      end

      
    end
  end
end
