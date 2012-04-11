module Diags
  USER = ENV['USER']
  LIB_DIR = File.dirname __FILE__
  BASE_DIR = File.dirname LIB_DIR
  TEMP_DIR = '/tmp/diags'
  CACHE_DIR = '/var/tmp/diags'

  require 'fileutils'
  require 'digest/md5'
  
  require 'diags/utils'
  
  require 'diags/node/base'
  require 'diags/node/package'
  require 'diags/node/image'
  
  require 'diags/cache/base'
  require 'diags/cache/file'

end


include Diags::Utils

sudo_mkdir Diags::CACHE_DIR
sudo_mkdir Diags::TEMP_DIR

