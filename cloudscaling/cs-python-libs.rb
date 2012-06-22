{
  'origin' => 'ssh://pd.cloudscaling.com:29418/python-libs',
  'sha1' => '6d0a5f40132f8317d5260a1444fa5ffdc8d0d194',
  'build_command' => "make",
  'version' => '1.0',
  'name' => 'cs-python-libs',
  'build_artifact' => '*.deb',
  'post-install' => "dpkg-trigger ldconfig",
}
