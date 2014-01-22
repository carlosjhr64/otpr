# Standard Library
require 'digest'
require 'timeout'
require 'tmpdir'
require 'securerandom'

# Gems
require 'test/unit'
require 'rainbow'
require 'base_convert'

# Rigs...
require 'otpr/config'
require 'otpr/entropy'

# THE LIBRARY FILE BEING TESTED
require 'otpr/helpers'

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

module Mock
  extend OTPR::Helpers
end

class Test_Helpers < Test::Unit::TestCase
  include OTPR

  def test_001_error_message
    Stub.clear

    test_mode = CONFIG[:test_mode]
    begin
      CONFIG[:test_mode] = true
      raise RuntimeError, :ok
    rescue
      Mock.error_message
    ensure
      CONFIG[:test_mode] = test_mode
    end

    assert_equal 1, Stub.count
    assert_equal 'ok', Stub.firsts
  end

  def test_002_error_message
    Stub.clear

    begin
      raise RuntimeError, :ok
    rescue
      Mock.error_message
    end

    assert_equal 1, Stub.count
    assert_equal "\e[31mOK\e[0m", Stub.firsts, '"OK" in caps, colored red.'
  end

  def test_003_error_message
    Stub.clear

    test_mode = CONFIG[:test_mode]
    CONFIG[:test_mode] = true
    Mock.error_message(:ok)
    CONFIG[:test_mode] = test_mode

    assert_equal 1, Stub.count
    assert_equal 'ok', Stub.firsts
  end

  def test_004_error_message
    Stub.clear

    Mock.error_message(:ok)

    assert_equal 1, Stub.count
    assert_equal "\e[31mOK\e[0m", Stub.firsts, '"OK" in caps, colored red.'
  end

  def test_005_ask
    Stub.clear
    STDIN.puts ' Y '
    y = Mock.ask('Why?')
    assert_equal 'Y', y
    assert_equal 'Why?', Stub.lasts
  end

  def test_006_ask
    Stub.clear
    STDIN.puts " Y \n"
    y = Mock.ask('Why?', true)
    assert_equal 'Y', y
    assert_nil Stub.last
  end

  def test_007_pin
    Stub.clear
    STDIN.puts "abc\n"
    STDIN.puts "abc\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    assert_equal 'abc', pin
  end

  def test_008_pin
    Stub.clear
    STDIN.puts "abc\n"
    STDIN.puts "xyz\n"
    STDIN.puts "123\n"
    STDIN.puts "123\n"
    STDIN.puts "abc\n"
    STDIN.puts "abc\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Gets the first pin entered twice in a row
    assert_equal '123', pin
  end

  def test_009_pin
    Stub.clear
    STDIN.puts "a.bc\n"
    STDIN.puts "a.bc\n"
    STDIN.puts "a.bc\n"
    STDIN.puts "abc\n"
    STDIN.puts "abc\n"
    STDIN.puts "a.bc\n"
    STDIN.puts "a.bc\n"
    STDIN.puts "a.bc\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Gets the first valid pin entered twice in a row
    assert_equal 'abc', pin
  end

  def test_010_pin
    Stub.clear
    STDIN.puts "  abc \n"
    STDIN.puts "abc\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Strips
    assert_equal 'abc', pin
  end

  def test_011_pin
    Stub.clear
    STDIN.puts "abc"
    STDIN.puts "abc"
    STDIN.puts "abcd"
    STDIN.puts "abcd\n"
    STDIN.puts "abc\n"
    STDIN.puts "abc\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin({:pin_min=>4}) }
    assert_equal 'abcd', pin
  end

  def test_012_pin
    Stub.clear
    STDIN.puts "abc"
    STDIN.puts "abc"
    STDIN.puts "abcde"
    STDIN.puts "abcde"
    STDIN.puts "abcd"
    STDIN.puts "abcd"
    STDIN.puts "abc"
    STDIN.puts "abc"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin({:pin_min=>4,:pin_max=>4}) }
    assert_equal 'abcd', pin
  end

# def test_014_get_salt
#   Stub.clear
#   tmpdir = Dir.mktmpdir
#   salt = Mock.get_salt(tmpdir)
#   assert_equal 1, Stub.count
#   refute_nil Stub.firsts=~/Writting.*salt/
#   refute_nil salt=~/^[[:graph:]]{40}$/
#   Stub.clear
#   salt2 = Mock.get_salt(tmpdir)
#   assert_equal 0, Stub.count
#   assert_equal salt, salt2
# end

  def test_014_delete_pads
    Stub.clear
    test_mode, CONFIG[:test_mode] = CONFIG[:test_mode], true

    tmpdir = Dir.mktmpdir
    zin    = File.join tmpdir, 'zin'
    zang   = File.join tmpdir, 'zang'
    Dir.mkdir zin
    Dir.mkdir zang

    # Deleting empty zin and zang (zang unsalted)
    Mock.delete_pads(zin, zang)
    assert_equal 2, Stub.count
    refute_nil Stub.firsts=~/no.*salt/
    assert_equal 'zang_empty0', Stub.lasts

    Stub.clear

    # Deleting empty zin, zang with 1 unpaired file (zang unsalted)
    system("touch #{zang}/abc")
    Mock.delete_pads(zin, zang)
    assert_equal 2, Stub.count
    refute_nil Stub.firsts=~/no.*salt/
    assert_equal 'zang_empty1', Stub.lasts
    assert system("rm #{zang}/abc")

    Stub.clear

    # Deleting zin and zang, unsalted zang
    system("touch #{zin}/abc")
    system("touch #{zang}/abc")
    Mock.delete_pads(zin, zang)
    assert_equal 2, Stub.count
    refute_nil Stub.firsts=~/no.*salt/
    assert_equal 'zang_empty0', Stub.lasts
    refute system("test -e #{zin}/abc")
    refute system("test -e #{zang}/abc")

    Stub.clear

    # THIS IS THE NORMAL SITUATION!
    # Deleting zin and zang, both salted
    system("touch #{zin}/abc")
    system("touch #{zin}/salt")
    system("touch #{zang}/abc")
    system("touch #{zang}/salt")
    Mock.delete_pads(zin, zang)
    assert_equal 0, Stub.count
    refute system("test -e #{zin}/abc")
    refute system("test -e #{zin}/salt")
    refute system("test -e #{zang}/abc")
    refute system("test -e #{zang}/salt")

    Stub.clear

    # Deleting zin and zang, both salted, zang has extra keys.
    system("touch #{zin}/abc")
    system("touch #{zin}/salt")
    system("touch #{zang}/abc")
    system("touch #{zang}/xyz")
    system("touch #{zang}/salt")
    Mock.delete_pads(zin, zang)
    assert_equal 1, Stub.count
    assert_equal 'zang_multiple', Stub.firsts
    assert system("rm #{zang}/xyz")
    assert system("rm #{zang}/salt")
    refute system("test -e #{zin}/abc")
    refute system("test -e #{zin}/salt")
    refute system("test -e #{zang}/abc")

    Stub.clear

    # We only delete regular files in zin
    system("touch #{zin}/abc")
    system("touch #{zin}/salt")
    system("touch #{zang}/abc")
    system("touch #{zang}/salt")
    system("mkdir #{zin}/saltine")
    Mock.delete_pads(zin, zang)
    assert_equal 1, Stub.count
    msg = Stub.firsts
    refute_nil msg=~/saltine/
    refute system("test -e #{zin}/abc")
    refute system("test -e #{zin}/salt")
    refute system("test -e #{zang}/abc")
    refute system("test -e #{zang}/salt")
    assert system("rmdir #{zin}/saltine")

    Stub.clear

    # Deleting unpaired key?
    system("touch #{zin}/abc")
    system("touch #{zin}/salt")
    system("touch #{zang}/salt")
    Mock.delete_pads(zin, zang)
    assert_equal 1, Stub.count
    msg = Stub.firsts
    refute_nil msg=~/Unpaired key deleted: abc/
    refute system("test -e #{zin}/abc")
    refute system("test -e #{zin}/salt")
    refute system("test -e #{zang}/abc")
    refute system("test -e #{zang}/salt")

    CONFIG[:test_mode] = test_mode 
  end
end
