{
  'origin' => 'git://github.com/ruby/ruby.git',
  'sha1' => 'ac3be749d5e94731559e50cf1d9d3dafe11f04d9',
  'build_command' => "autoconf && 
./configure --prefix=/usr/local --disable-install-doc && 
make clean && 
make && 
make install DESTDIR=$DIAGS_DESTINATION_DIR",
  'version' => '1.9.2-1',
  'name' => 'ruby',
  'post-install' => "dpkg-trigger ldconfig",
}
