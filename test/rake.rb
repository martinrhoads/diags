# require 'fileutils'
# require 'digest/md5' 
require File.join('.','lib','diags')

@diags_test_base = File.join Diags::BASE_DIR, 'test'
#@diags_test_base = File.join @diags_base, 'test'

@@diags_tmp_dir = Diags::TEMP_DIR


FileUtils.mkdir_p @@diags_tmp_dir


namespace :test do

  # TODO : find out out to really call all 
  desc "test all"
  task :all => [:base, :image, "cache:all" ]
  
  desc "base test"
  task :base do
    require File.join @diags_base, 'lib', 'diags'
    require File.join @diags_test_base, 'base'
  end

  desc "image test"
  task :image do 
    require File.join @diags_base, 'lib', 'diags'
    require File.join @diags_test_base, 'node', 'image'
  end

  namespace :cache do 

    desc "test all cache"
    task :all => [:file] 

    desc "test file"
    task :file do 
      require File.join @diags_base, 'lib', 'diags'
      require File.join @diags_test_base, 'cache', 'file'
    end

  end

end


