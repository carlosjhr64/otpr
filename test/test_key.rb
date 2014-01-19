# Gems
require 'test/unit'

# THE LIBRARY FILE BEING TESTED
require 'otpr/key'

class Test_Key < Test::Unit::TestCase
  include OTPR

  def test_001_key
    key = Key.new('abc')
    # keys is just a string...
    assert_equal 'abc', key
    # that responds to xor...
    assert key.respond_to?(:xor)
    z = key.xor('abc')
    assert_equal "\u0000\u0000\u0000", z
    c = key.xor('xyz')
    refute_equal 'xyz', c
    p = key.xor(c)
    assert_equal 'xyz', p
    # yep, it's an xor.
  end
end
