# Standard Libraries
require 'digest'

# Gems
require 'test/unit'
require 'base_convert'

# THE LIBRARY FILE BEING TESTED
require 'otpr/config'

class Test_Config < Test::Unit::TestCase
  include OTPR

  # Just verifying calculated values
  def test_001_values
    assert_equal 32,  DIGEST_LENGTH
    assert_equal 16,  CHKSUM_LENGTH
    assert_equal 256, ENTROPY
    assert_equal 64,  NIBBLES
    assert_equal 17,  WORDS
    assert_equal 16,  SBS # Standard/Hex Base Size
    assert_equal 91,  PPS # Passphrase Base Size
    assert_equal 62,  PNS # Pin Base Size

    assert_in_delta 1.229, PPK, 0.001
    assert_in_delta 1.343, PNK, 0.001

    assert_equal 40,  PPL
    assert_equal 22,  PNL

    assert_equal PPL, CONFIG[:secret_max]
    assert_equal PNL, CONFIG[:pin_max]
  end

  def test_002_extension
    a = {}
    a.extend Config
    assert_equal PNL, a[:pin_max]

    a = {:pin_max => 'PinMax'}
    a.extend Config
    assert_equal 'PinMax', a[:pin_max]
    assert_equal PPL, a[:secret_max]

    a = {:pin_max => 'PinMax', :secret_max => nil}
    a.extend Config
    assert_equal 'PinMax', a[:pin_max]
    assert_equal nil, a[:secret_max]
    assert_equal CONFIG[:inconsistent], a[:inconsistent]
    assert_equal 'OK', a[:ok]

    assert_nil a[:watchamacallit]
  end
end
