#!/usr/bin/env ruby

require 'minitest/autorun'

class TestDiagsBase < MiniTest::Unit::TestCase

  # we need minitest to run in order
  def self.test_order
    :alpha
  end
  
  def setup
    @diags = Diags::Node::Base.new()
    @package = Diags::Node::Package.new
    @image = Diags::Node::Image.new
  end

  def test_base_instantiator
    assert true
  end

end

