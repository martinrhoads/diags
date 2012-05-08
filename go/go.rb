#!/usr/bin/env ruby


# this is to try out a sample of what diags may look like to the end user

require File.join(File.dirname(__FILE__),'..','lib','diags')


# git_repo1 = Diags::Node::Git.new('git@github.com:cloudscaling/sheep.git', '878b84b4b404f95f3389d8163114cc497c33ca2e')
# git_repo2 = Diags::Node::Git.new('git@github.com:ermal14/diags.git', '117f7e9d5723bb448b50959d1950ea6c632e4a65')

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



image = Diags::Node::Image.new('precise',packages)
custom_image = Diags::Node::CustomImage.new(image,script)
custom_image.go  
puts "custom_image.state is #{custom_image.state}"

