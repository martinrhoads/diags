#!/usr/bin/env ruby

require 'minitest/autorun'



# test repo node 
class TestRepo < MiniTest::Unit::TestCase

  def setup
    @repo = Diags::Node::Repo.new
  end

  def test_foo
    @repo.build
    assert true
  end

end

