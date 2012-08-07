{
  'cs-python-libs' => {
    'origin' => 'ssh://pd.cloudscaling.com:29418/python-libs',
    'sha1' => '6d0a5f40132f8317d5260a1444fa5ffdc8d0d194',
    'build_command' => "make",
    'version' => '1.0',
    'build_artifact' => '*.deb',
    'post-install' => "dpkg-trigger ldconfig",
    'type' => 'PackageFile',
  },
  'kyotocabinet' => {
    'origin' => 'gitolite@pd.cloudscaling.com:kyotocabinet',
    'sha1' => 'b38a3f6a03c4932028b7db7397c6effdccaa42ee',
    'build_command' => "./configure --prefix=/usr/local && 
make clean && 
make && 
make install DESTDIR=$DIAGS_DESTINATION_DIR",
    'version' => '1.2.68',
    'post-install' => "dpkg-trigger ldconfig",
    'type' => 'PackageDir',
  },
  'mini-boot' => {
    'origin' => 'ssh://pd.cloudscaling.com:29418/mini-boot',
    'branch' => 'develop',
    'build_command' => "sudo ./makeit verbose",
    'version' => '1.0',
    'post-install' => "dpkg-trigger ldconfig",
    'build_artifact' => 'miniboot1.0_initrd.gz',
    'type' => 'PackageMiniboot',
  },
  'ruby' => {
    'origin' => 'git://github.com/ruby/ruby.git',
    'sha1' => 'ac3be749d5e94731559e50cf1d9d3dafe11f04d9',
    'build_command' => "autoconf && 
./configure --prefix=/usr/local --disable-install-doc && 
make clean && 
make && 
make install DESTDIR=$DIAGS_DESTINATION_DIR",
    'version' => '1.9.2-1',
    'post-install' => "dpkg-trigger ldconfig && /usr/local/bin/gem installer bundler --version 1.1.4",
    'type' => 'PackageDir',
  },
  'substratum' => {      
    'version' => '1.2.3',
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
         /usr/local/bin/bundle install --no-deployment --binstubs &&
         /usr/local/bin/bundle install --deployment --binstubs
       ",
    'type' => 'PackageSubstratum',
    'dependency_packages' => {
      'substratum-0.5.3' => {
        'origin' => 'ssh://pd.cloudscaling.com:29418/substratum',
        'branch' => 'develop',
        'build_command' => 'rake build',
        'build_artifact' => 'pkg/substratum-*.gem',
      },
      'substratum-cli-0.5.3' => {
        'origin' => 'ssh://pd.cloudscaling.com:29418/substratum-cli',
        'branch' => 'develop',
        'build_command' => 'rake build',
        'build_artifact' => 'pkg/substratum-cli-*.gem',
      },
      'jason-schema' => {
        'origin' => 'git://github.com/shadoi/json-schema.git',
        'branch' => 'master',
        'build_command' => '/usr/local/bin/gem build json-schema.gemspec',
        'build_artifact' => 'json-schema-*.gem',
      }
    },
  },
  'zeromq' => {
    'origin' => 'git://github.com/zeromq/zeromq2-x.git',
    'sha1' => 'v2.1.8',
    'build_command' => "./autogen.sh && 
./configure --prefix=/usr/local --with-pgm && 
make clean && 
make  && 
make install DESTDIR=$DIAGS_DESTINATION_DIR",
    'version' => '2.1.8',
    'post-install' => "dpkg-trigger ldconfig",
    'type' => 'PackageDir',
  },
}