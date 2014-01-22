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
  # And forces code review of any changes ;)
  def test_001_defining_configuration
    # Defining Configuration
    assert_equal Digest::SHA512, DIGEST
    assert_equal Digest::MD5,    CHKSUM
    assert_equal 256,            ENTROPY
    assert_equal :qgraph,        PPT
    assert_equal :word,          PNT
    assert_equal true,           STRIP
    # Standard Base Type
    assert_equal :hex, SBT
  end

  def test_002_computed_configuration
    assert_equal 64, DIGEST_LENGTH
    assert_equal 16, CHKSUM_LENGTH
    # Base sizes
    assert_equal 16,    SBS
    assert_equal 91,    PPS
    assert_equal 62,    PNS
    assert_equal 99171, DWS
    # Conversion constants
    assert_in_delta 0.693, LG2, 0.001
    assert_in_delta 0.250, SBK, 0.001
    assert_in_delta 0.153, PPK, 0.001
    assert_in_delta 0.167, PNK, 0.001
    assert_in_delta 0.060, DWK, 0.001
    # Lengths based on entropy
    assert_equal 40, PPE
    assert_equal 44, PNE
    assert_equal 16, DWE
    # Lengths based on digest
    assert_equal 80, PPD
    assert_equal 87, PND
    assert_equal 32, DWD
    # Lengths based on checksum
    assert_equal 21, PPC
    assert_equal 22, PNC
    assert_equal  9, DWC
    # Desired entropy in nibbles
    assert_equal 64, NIBBLES
  end

  def test_003_config
    # pin_max is based on checksum's entropy
    assert_equal PNC, CONFIG[:pin_max]
    assert_equal 22,  CONFIG[:pin_max]
    # secret_max is based on digest's length
    assert_equal DIGEST_LENGTH, CONFIG[:secret_max]
    assert_equal 64,            CONFIG[:secret_max]
  end

  def test_004_extension
    a = {}
    a.extend Config
    assert_equal PNC, a[:pin_max]

    a = {:pin_max => 'PinMax'}
    a.extend Config
    assert_equal 'PinMax', a[:pin_max]
    assert_equal DIGEST_LENGTH, a[:secret_max]

    a = {:pin_max => 'PinMax', :secret_max => nil}
    a.extend Config
    assert_equal 'PinMax', a[:pin_max]
    assert_equal nil, a[:secret_max]
    assert_equal CONFIG[:inconsistent], a[:inconsistent]
    assert_equal 'OK', a[:ok]

    assert_nil a[:watchamacallit]
  end
end
