{
  'origin' => 'git://github.com/zeromq/zeromq2-x.git',
  'sha1' => 'v2.1.8',
  'build_command' => "./autogen.sh && 
./configure --prefix=/usr/local --with-pgm && 
make clean && 
make  && 
make install DESTDIR=$DIAGS_DESTINATION_DIR",
  'version' => '2.1.8',
  'name' => 'zeromq',
  'post-install' => "dpkg-trigger ldconfig",
}
