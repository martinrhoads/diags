@diags_test_base = File.join @diags_base, 'test'

namespace :test do
  
  desc "base test"
  task :base do
    require File.join @diags_base, 'lib', 'diags'
    require File.join @diags_test_base, 'base'
  end
  
end


