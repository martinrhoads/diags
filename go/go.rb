#!/usr/bin/env ruby

# this is to try out a sample of what diags may look like to the end user

substratum_chroot_script = File.read(File.join(File.dirname(File.expand_path(__FILE__)),'scripts','substratum_chroot_script.sh'))
script_template = File.read(File.join(File.dirname(File.expand_path(__FILE__)),'templates','build_ruby.erb'))


require File.join(File.dirname(__FILE__),'..','lib','diags')

post_install = <<EOI
#!/bin/sh
dpkg-trigger ldconfig
EOI

ruby_repo_opts = {:origin => "git://github.com/ruby/ruby.git", :branch => 'ruby_1_9_2'}
ruby_repo = Diags::Node::Git.new(ruby_repo_opts)

include_directories = [
                       "",
]

# opts = {
#   :repo => ruby_repo, 
#   :script_template => script_template, 
#   :destination_file => '/tmp/bad', 
#   :post_install => post_install, 
#   :name => 'ruby1.9.2',
#   :version => '1.3.2.4',

# }

# package1 = Diags::Node::Package.new(opts)
# package_path = package1.go
# STDERR.puts "package_path = #{package_path}"

# Kernel.exit 1


# git1_opts = {:origin => 'git@github.com:cloudscaling/sheep.git', :sha1 => '878b84b4b404f95f3389d8163114cc497c33ca2e' }
# git2_opts = {:origin => 'git@github.com:ermal14/diags.git', :branch => 'develop' }

# git_repo1 = Diags::Node::Git.new(git1_opts )
# git_repo2 = Diags::Node::Git.new(git2_opts)

# some_dir1 = git_repo1.go
# some_dir2 = git_repo2.go
# puts "some_dir1 is #{some_dir1}"
# puts "some_dir2 is #{some_dir2}"


packages = %w{
  debconf-utils 
  syslinux 
  mtools 
  apt-utils 
  nfs-common 
  autofs 
  ubuntu-standard 
  console-setup 
  kbd 
  xfsprogs 
  sudo 
  ureadahead 
  linux-image-server 
  linux-headers-generic 
  grub 
  grub-pc 
  acpid 
  vim 
  curl 
  wget 
  emacs23-nox 
  openssh-server 
  avahi-daemon 
  bash-completion 
  vlan 
  iputils-ping 
  ethtool 
  rsync 
  tcpdump 
  strace 
  lsof 
  ifenslave-2.6 
  language-pack-en 
  less 
  git-core 
  git
}

files = {}

base_image = Diags::Node::Image.new('precise',packages)
substratum_image = Diags::Node::CustomImage.new(base_image,substratum_chroot_script)
substratum_packaged = Diags::Node::PackageImage.new(substratum_image)
substratum_packaged.go

# script = File.read(File.join(File.dirname(File.expand_path(__FILE__)),'scripts','chroot_script.sh'))
# image = Diags::Node::Image.new('precise',packages)
# puts "image is #{image}"
# custom_image = Diags::Node::CustomImage.new(image,script)
# packaged_image = Diags::Node::PackageImage.new(custom_image)

# packaged_image.go 

  
