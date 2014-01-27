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
    STDIN.puts "abc1\n"
    STDIN.puts "abc1\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    assert_equal 'abc1', pin
  end

  def test_008_pin
    Stub.clear
    STDIN.puts "abc1\n"
    STDIN.puts "xyz1\n"
    STDIN.puts "123N\n"
    STDIN.puts "123N\n"
    STDIN.puts "abc1\n"
    STDIN.puts "abc1\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Gets the first pin entered twice in a row
    assert_equal '123N', pin
  end

  def test_009_pin
    Stub.clear
    STDIN.puts "a.bc1\n"
    STDIN.puts "a.bc1\n"
    STDIN.puts "a.bc1\n"
    STDIN.puts "abc1\n"
    STDIN.puts "abc1\n"
    STDIN.puts "a.bc1\n"
    STDIN.puts "a.bc1\n"
    STDIN.puts "a.bc1\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Gets the first valid pin entered twice in a row
    assert_equal 'abc1', pin
  end

  def test_010_pin
    Stub.clear
    STDIN.puts "  abc1 \n"
    STDIN.puts "abc1\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Strips
    assert_equal 'abc1', pin
  end

  def test_011_pin
    Stub.clear
    STDIN.puts "abc1"
    STDIN.puts "abc1"
    STDIN.puts "abcd1"
    STDIN.puts "abcd1\n"
    STDIN.puts "abc1\n"
    STDIN.puts "abc1\n"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin({:pin_min=>5}) }
    assert_equal 'abcd1', pin
  end

  def test_012_pin
    Stub.clear
    STDIN.puts "abc1"
    STDIN.puts "abc1"
    STDIN.puts "abcde1"
    STDIN.puts "abcde1"
    STDIN.puts "abcd1"
    STDIN.puts "abcd1"
    STDIN.puts "abc1"
    STDIN.puts "abc1"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin({:pin_min=>5,:pin_max=>5}) }
    assert_equal 'abcd1', pin
  end

  def test_013_pin_numbers
    Stub.clear
    # Numbers...
    STDIN.puts "123"
    STDIN.puts "123"
    STDIN.puts "1234"
    STDIN.puts "1234"
    STDIN.puts "12345"
    STDIN.puts "12345"
    STDIN.puts "123456"
    STDIN.puts "123456"
    STDIN.puts "1234567"
    STDIN.puts "1234567"
    STDIN.puts "12345678"
    STDIN.puts "12345678"
    STDIN.puts "123456789"
    STDIN.puts "123456789"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Needs at least 7 digits
    assert_equal '1234567', pin
  end

  def test_014_pin_words
    Stub.clear
    # Numbers...
    STDIN.puts "abc"
    STDIN.puts "abc"
    STDIN.puts "abca"
    STDIN.puts "abca"
    STDIN.puts "abcab"
    STDIN.puts "abcab"
    STDIN.puts "abcabc"
    STDIN.puts "abcabc"
    STDIN.puts "abcabca"
    STDIN.puts "abcabca"
    STDIN.puts "abcabcab"
    STDIN.puts "abcabcab"
    STDIN.puts "abcabcabc"
    STDIN.puts "abcabcabc"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Needs at least 5
    assert_equal 'abcab', pin
  end

  def test_015_pin_caps
    Stub.clear
    # Numbers...
    STDIN.puts "ABC"
    STDIN.puts "ABC"
    STDIN.puts "ABCA"
    STDIN.puts "ABCA"
    STDIN.puts "ABCAB"
    STDIN.puts "ABCAB"
    STDIN.puts "ABCABC"
    STDIN.puts "ABCABC"
    STDIN.puts "ABCABCA"
    STDIN.puts "ABCABCA"
    STDIN.puts "ABCABCAB"
    STDIN.puts "ABCABCAB"
    STDIN.puts "ABCABCABC"
    STDIN.puts "ABCABCABC"
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin }
    # Needs at least 5
    assert_equal 'ABCAB', pin
  end

  def test_016_pin_symbols
    Stub.clear
    # Numbers...
    STDIN.puts '!@#'
    STDIN.puts '!@#'
    STDIN.puts '!@#$'
    STDIN.puts '!@#$'
    STDIN.puts '!@#$%'
    STDIN.puts '!@#$%'
    STDIN.puts '!@#$%^'
    STDIN.puts '!@#$%^'
    STDIN.puts '!@#$%^&*('
    STDIN.puts '!@#$%^&*('
    STDIN.puts '!@#$%^&*()'
    STDIN.puts '!@#$%^&*()'
    STDIN.puts '!@#$%^&*()-'
    STDIN.puts '!@#$%^&*()-'
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin({:pin_accept=>CONFIG[:secret_accept]}) }
    # Needs at least 5
    assert_equal '!@#$%', pin
  end

  def test_017_pin_mix
    Stub.clear
    # Numbers...
    STDIN.puts 'a'
    STDIN.puts 'a'
    STDIN.puts 'aA'
    STDIN.puts 'aA'
    STDIN.puts 'aA1'
    STDIN.puts 'aA1'
    STDIN.puts 'aA1!'
    STDIN.puts 'aA1!'
    STDIN.puts 'aA1!b'
    STDIN.puts 'aA1!b'
    STDIN.puts 'aA1!bB'
    STDIN.puts 'aA1!bB'
    STDIN.puts 'aA1!bB2'
    STDIN.puts 'aA1!bB2'
    STDIN.puts 'aA1!bB2@'
    STDIN.puts 'aA1!bB2@'
    STDIN.puts 'aA1!bB2@c'
    STDIN.puts 'aA1!bB2@c'
    pin = nil
    Timeout::timeout(1) { pin = Mock.user_pin({:pin_accept=>CONFIG[:secret_accept]}) }
    # Needs at least 3
    assert_equal 'aA1', pin
  end

  def test_018_delete_pins
    Stub.clear
    test_mode, CONFIG[:test_mode] = CONFIG[:test_mode], true

    tmpdir = Dir.mktmpdir
    zin    = File.join tmpdir, 'zin'
    zang   = File.join tmpdir, 'zang'
    Dir.mkdir zin
    Dir.mkdir zang

    # Deleting empty zin and zang (zang unsalted)
    Mock.delete_pins(zin, zang)
    assert_equal 2, Stub.count
    refute_nil Stub.firsts=~/no.*salt/
    assert_equal 'zang_empty0', Stub.lasts

    Stub.clear

    # Deleting empty zin, zang with 1 unpaired file (zang unsalted)
    system("touch #{zang}/abc")
    Mock.delete_pins(zin, zang)
    assert_equal 2, Stub.count
    refute_nil Stub.firsts=~/no.*salt/
    assert_equal 'zang_empty1', Stub.lasts
    assert system("rm #{zang}/abc")

    Stub.clear

    # Deleting zin and zang, unsalted zang
    system("touch #{zin}/abc")
    system("touch #{zang}/abc")
    Mock.delete_pins(zin, zang)
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
    Mock.delete_pins(zin, zang)
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
    Mock.delete_pins(zin, zang)
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
    Mock.delete_pins(zin, zang)
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
    Mock.delete_pins(zin, zang)
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
