module Diags
  module Node
    class Base

      def initialize(opts={})
        @parents=[]
        @artifacts=[]
        @state=nil
      end
      
      def state
        if @state.nil?
          state=''
          state << self.class.name
          @parents.each {|parent| state << parent.state }
          @state=state
        end
        return @state
      end

      def build()
        raise "not implmented"
      end
      
      def rebuild()
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

      def my_state
      end

      
    end
  end
end
