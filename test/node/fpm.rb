#!/usr/bin/env ruby

require 'minitest/autorun'

# test package node 
class TestPackageSubstratum < MiniTest::Unit::TestCase

  def setup
    @config = {
      'apt_dependencies' => [
                             "kyotocabinet",
                             "libffi6",
                             "libpcap0.8",
                             "mini-boot",
                             "ruby1.9.2-1",
                             "rubygem-bundler",
                             "syslinux",
                             "zeromq"
                            ],
      'origin' => 'ssh://pd.cloudscaling.com:29418/substratum-services',
      'branch' => 'develop',
      'build_command' => "
         /usr/local/bin/bundle install --no-deployment --binstubs
         /usr/local/bin/bundle install --deployment --binstubs
       ",
      'dependency_packages' => {
        'substratum-0.5.1' => {
          'origin' => 'ssh://pd.cloudscaling.com:29418/substratum',
          'branch' => 'develop',
          'build_command' => 'rake build',
          'build_artifact' => 'pkg/substratum-0.5.1.gem',
        },
        'substratum-cli-0.5.1' => {
          'origin' => 'ssh://pd.cloudscaling.com:29418/substratum-cli',
          'branch' => 'develop',
          'build_command' => 'rake build',
          'build_artifact' => 'pkg/substratum-cli-0.5.1.gem',
        },
        'jason-schema' => {
          'origin' => 'git://github.com/shadoi/json-schema.git',
          'branch' => 'master',
          'build_command' => '/usr/local/bin/gem build json-schema.gemspec',
          'build_artifact' => 'json-schema-1.0.5.gem',
        }
      },
    }
    
    @package = Diags::Node::PackageSubstratum.new @config
    @fpm_hash = {
      'apt_dependencies' => @config['apt_dependencies'],
      'version' => '0.5.1',
      'name' => 'substratum-services',
      'package_dependency' => @package,
      'config_files' => '/etc/default/substratum',
      'post-install' => "#!/bin/sh
dpkg-trigger ldconfig 
"
    }

    @fpm_package = Diags::Node::FPM.new(@fpm_hash)
  end
  
  def test_fpm
      puts "in building fpm" 
      dir = @fpm_package.set_state
      puts "build fpm package in #{dir}"
      assert true
    end
    
end
  
  
