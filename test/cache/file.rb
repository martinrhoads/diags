#!/usr/bin/env ruby

require 'minitest/autorun'

# test file cache
class TestCacheFile < MiniTest::Unit::TestCase

#include Diags
#include Diags::Utils

  def setup
    @path = File.join(@@diags_tmp_dir,'file-' + rand(9999).to_s )

    Diags::Utils::random_dir
    @path = File.join(Diags::Utils::random_file)
STDERR.puts "@path is @path"
    @contents = @path
    @md5 = Digest::MD5.hexdigest(@contents)
    File.open(@path, 'w') {|f| f.write(@contents) }
    Diags::Cache::File.save_state @path
    @cache_file = File.join(Diags::Cache::File::CACHE_DIR,@md5[0,2],@md5)
  end

  def test_save_state
    assert File.exists?(@cache_file),"cache file does not exist #{@cache_file}"
    assert Digest::MD5.hexdigest(File.read(@cache_file)) == @md5, "md5 of cache file is not correct"
  end

  def test_set_state
    
  end


end

