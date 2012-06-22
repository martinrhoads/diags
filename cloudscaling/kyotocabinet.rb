{
  'origin' => 'gitolite@pd.cloudscaling.com:kyotocabinet',
  'sha1' => 'b38a3f6a03c4932028b7db7397c6effdccaa42ee',
  'build_command' => "./configure --prefix=/usr/local && 
make clean && 
make && 
make install DESTDIR=$DIAGS_DESTINATION_DIR",
  'version' => '1.2.68',
  'name' => 'kyotocabinet',
  'post-install' => "dpkg-trigger ldconfig",
}
