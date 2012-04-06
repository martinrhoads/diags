#!/usr/bin/env ruby

require 'minitest/autorun'

class TestDiagsBase < MiniTest::Unit::TestCase

  # we need minitest to run in order
  def self.test_order
    :alpha
  end
  
  def setup
    @diags = Diags::Base.new()
    @package = Diags::Package.new
    @image = Diags::Image.new
  end

  def test_base_instantiator
    assert true
  end

end

