{
  'origin' => 'ssh://pd.cloudscaling.com:29418/mini-boot',
  'branch' => 'develop',
  'build_command' => "sudo ./makeit verbose",
  'version' => '1.0',
  'name' => 'mini-boot',
  'post-install' => "dpkg-trigger ldconfig",
  'build_artifact' => 'miniboot1.0_initrd.gz',
}
