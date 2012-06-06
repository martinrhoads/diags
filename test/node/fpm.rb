#!/usr/bin/env ruby

require 'minitest/autorun'

# test package node 
class TestPackageSubstratum < MiniTest::Unit::TestCase

  def setup
    @config = {
      'repos' => {
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
    }

    @substratum_services_hash = {
      'origin' => 'ssh://pd.cloudscaling.com:29418/substratum-services',
      'branch' => 'develop',
      'build_command' => "
         /usr/local/bin/bundle install --no-deployment --binstubs
         /usr/local/bin/bundle install --deployment --binstubs
       ",
      'build_artifact' => '*',
    }

    
    # build dependencies
    @substratum_services_hash['dependencies'] = {}
    @config['repos'].each do |repo,repo_options| 
      repo_options['repo'] = Diags::Node::Git.new(repo_options)
      STDERR.puts "creating package"
      STDERR.puts "repo_options are #{repo_options}"
      package = Diags::Node::Package.new(repo_options)
      @substratum_services_hash['dependencies'][repo] = package
      package.go
    end
    
    @substratum_git_repo = Diags::Node::Git.new(@substratum_services_hash)
    @substratum_services_hash['repo'] = @substratum_git_repo

    @package = Diags::Node::PackageSubstratum.new @substratum_services_hash
    
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
    

    @frm_package = Diags::Node::FPM.new(@fpm_hash)
  end
  
  def test_foo
    puts "in foo"
    dir = @frm_package.go
    puts "built frm package in #{dir}"
    assert true
  end

end

