# Standard Library
require 'digest'
require 'tmpdir'
require 'securerandom'

# Gems
require 'test/unit'
require 'base_convert'
require 'rainbow'

# Rigs...
require 'otpr/config'
require 'otpr/entropy'

# THE LIBRARY FILE BEING TESTED
require 'otpr/otpr'

module Stub
  CALLS = []
  def self.[](n)
    CALLS[n]
  end
  def self.clear
    CALLS.clear
  end
  def self.count
    CALLS.length
  end
  def self.first
    CALLS.first
  end
  def self.firsts
    CALLS.first.first
  end
  def self.last
    CALLS.last
  end
  def self.lasts
    CALLS.last.last
  end
  def print(*args)
    CALLS.push(args)
  end
  def puts(*args)
    CALLS.push(args)
  end
  def gets
    CALLS.shift.first
  end
end
STDERR.extend Stub
STDIN.extend Stub
STDOUT.extend Stub

class Test_Otpr_Salt < Test::Unit::TestCase
  include OTPR

  def test_001_otpr_salt
    Stub.clear
    tmpdir = Dir.mktmpdir
    salt = Otpr.salt(tmpdir)
    assert_equal 1, Stub.count
    refute_nil Stub.firsts=~/Writting.*salt/
    refute_nil salt=~/^[[:graph:]]{40}$/
    Stub.clear
    salt2 = Otpr.salt(tmpdir)
    assert_equal 0, Stub.count
    assert_equal salt, salt2
  end

end
