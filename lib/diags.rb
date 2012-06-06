$LOAD_PATH.unshift('.')
Dir.chdir(File.dirname __FILE__)

module Diags

  USER = ENV['USER']
  LIB_DIR = File.dirname __FILE__
  BASE_DIR = File.dirname LIB_DIR
  TEMP_DIR = '/tmp/diags'
  CACHE_DIR = '/var/tmp/diags'
  GIT_CACHE_DIR = File.join CACHE_DIR, 'git'

  require 'fileutils'
  require 'digest/md5'
  require 'diags/utils'
  require 'logger'
  require 'erb'
  require 'fpm'
  require 'pry'
  
  require 'diags/node/base'
  require 'diags/node/package'
  require 'diags/node/package_substratum'
  require 'diags/node/image'
  require 'diags/node/server'
  require 'diags/node/custom_image'
  require 'diags/node/image_seed'
  require 'diags/node/package_image'
  require 'diags/node/git'
  
  require 'diags/cache/base'
  require 'diags/cache/file'
  require 'diags/cache/directory'

end

include Diags
include Diags::Utils

sudo_mkdir Diags::TEMP_DIR
sudo_mkdir Diags::CACHE_DIR

unless Dir.exists? Diags::GIT_CACHE_DIR
  sudo_mkdir Diags::GIT_CACHE_DIR
  run "git --git-dir=#{Diags::GIT_CACHE_DIR} init --bare"
end


unless Dir.exists? GIT_CACHE_DIR
  run "git init --bare #{GIT_CACHE_DIR}"
end

logger.info "starting diags run..."
