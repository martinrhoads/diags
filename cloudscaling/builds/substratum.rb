{      
  'name' => 'substratum',
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
}
