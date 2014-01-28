# Gems
require 'test/unit'

# THE LIBRARY FILE BEING TESTED
require 'otpr/version'

class Test_Version < Test::Unit::TestCase
  def test_001_version
    assert_equal '2.0.0', OTPR::VERSION
  end
end
