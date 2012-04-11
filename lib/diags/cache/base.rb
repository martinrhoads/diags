module Diags
  module Cache

    class Base
      include Diags::Cache
      @diags_cache_dir
      def initialize(opts={})
      end
      
      def save_state()
        raise "not implmented"
      end
      
      def restore_state()
        raise "not implmented"
      end
      
      # delete_state? 
    end
  end
end

