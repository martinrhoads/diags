#!/usr/bin/env ruby

require 'minitest/autorun'

# test image node 
class TestImage < MiniTest::Unit::TestCase

  def setup
    @image = Diags::Node::SeedImage.new
  end

  def test_seed

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

    base_image = Diags::Node::Image.new('precise',packages)
    
    upstart_script = << EOS
    echo hi
EOS
    opts = {
      
    }
    upstart_image = Diags::Node::SeedImage.new(opts)
    
    puts "in foo" 
    @image.build
    puts "@image.hash is ::" + @image.hash
    puts "::end hash"
#    @image.rebuild
    assert true
  end

end

