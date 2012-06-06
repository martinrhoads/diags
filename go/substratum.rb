#!/usr/bin/env ruby

## substratum build 

require File.join(File.dirname(__FILE__),'..','lib','diags')
require 'pry'

# config file
config = {
  :repos => {
    'substratum' => {
      :origin => 'ssh://pd.cloudscaling.com:29418/substratum',
      :branch => 'develop',
      :build_command => 'rake build',
      :build_artifact => 'pkg/*.gem',
    },
    'substratum-services' => {
      :origin => 'ssh://pd.cloudscaling.com:29418/substratum-services',
      :branch => 'develop',
      :build_command => "
        /usr/local/bin/bundle install --no-deployment --binstubs
        /usr/local/bin/bundle install --deployment --binstubs
      ",
      :build_artifact => '*',
    },
    'substratum-cli' => {
      :origin => 'ssh://pd.cloudscaling.com:29418/substratum-cli',
      :branch => 'develop',
      :build_command => 'rake build',
      :build_artifact => 'pkg/*.gem',
    },
    'jason-schema' => {
      :origin => 'git://github.com/shadoi/json-schema.git',
      :branch => 'master',
      :build_command => '/usr/local/bin/gem build json-schema.gemspec',
      :build_artifact => '*.gem',
    }
  },
  :apt_dependencies => [
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



# check out repos
config[:repos].each do |repo,repo_options| 
  repo_options[:repo] = Diags::Node::Git.new(repo_options)
  package = Diags::Node::Package.new(repo_options)
  package.go
end

puts "config is #{config.inspect}"

Kernel.exit 0


build_script = <<end_of_build_script



patch_version=$(git --git-dir=$SHEEP_DIR/cache/repos/substratum-services rev-list --all  | wc -l)
PSM_VERSION=$(cat substratum-services/VERSION)-${patch_version}
debname=$SHEEP_PARENT_MODULE_DIR/debs/substratum-services-${PSM_VERSION}-${ARCH}.deb
gem_bindir=$(/usr/local/bin/gem env |grep "EXECUTABLE DIRECTORY"| cut -f2 -d:)


rsync -avz --specials --links substratum-services/ $psm_root/

mkdir -p $build_root/etc/init
mkdir -p $build_root/etc/logrotate.d
mkdir -p $build_root/var/log/substratum
mkdir -p $build_root/var/run/substratum
mkdir -p $build_root/var/tmp/substratum
mkdir -p $build_root/etc/default
mkdir -p $build_root/etc/substratum

cp $psm_root/etc/default/substratum $build_root/etc/default/substratum
cp $psm_root/examples/config.json $build_root/etc/substratum/config.json.example
cp $psm_root/etc/init/substratum-*.conf $build_root/etc/init
cp $psm_root/etc/logrotate.d/substratum-logs $build_root/etc/logrotate.d/substratum-logs

mkdir -p $build_root/usr/bin
cd $build_root/usr/bin
ln -s ../../srv/substratum/services/bin/substratum substratum
cd $SHEEP_PARENT_MODULE_DIR

${gem_bindir}/fpm --post-install `pwd`/post-install -s dir -t deb -n substratum-services -v $PSM_VERSION -C $build_root -p $SHEEP_PARENT_MODULE_DIR/debs/substratum-services-${PSM_VERSION}-${ARCH}.deb --config-files /etc/default/substratum  srv etc var usr

end_of_build_script



post_install = <<EOI
#!/bin/sh
dpkg-trigger ldconfig
EOI

ruby_repo_opts = {:origin => "git://github.com/ruby/ruby.git", :branch => 'ruby_1_9_2'}
ruby_repo = Diags::Node::Git.new(ruby_repo_opts)


opts = {
  :repo => ruby_repo, 
  :script_template => script_template, 
  :destination_file => '/tmp/bad', 
  :post_install => post_install, 
  :name => 'ruby1.9.2',
  :version => '1.3.2.4',

}

package1 = Diags::Node::Package.new(opts)
package_path = package1.go
STDERR.puts "package_path = #{package_path}"

