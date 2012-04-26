#!/usr/bin/env ruby

require 'minitest/autorun'



# test image node 
class TestImage < MiniTest::Unit::TestCase

  def setup
    @image = Diags::Node::Image.new
  end

  def test_foo
    puts "in foo" 
    @image.build
    puts "@image.hash is ::" + @image.hash
    puts "::end hash"
#    @image.rebuild
    assert true
  end

end

