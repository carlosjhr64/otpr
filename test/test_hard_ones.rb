# Standard Library
require 'digest'
require 'timeout'
require 'tmpdir'

# Gems
require 'test/unit'
require 'rainbow'
require 'base_convert'

# This Gem
require 'otpr'

# Testing a few hard cases

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
    (tmp=CALLS.first)? tmp.first : nil
  end
  def self.last
    CALLS.last
  end
  def self.lasts
    (tmp=CALLS.last)? tmp.last : nil
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
#STDERR.extend Stub
STDIN.extend  Stub
#STDOUT.extend Stub

class Test_Hard_Ones < Test::Unit::TestCase
  include OTPR

  def test_001_entropy_user
    STDIN.puts 'One Two Three Four Five'
    STDIN.puts 'Six Seven Eight Nine Ten'
    STDIN.puts 'Eleven Twelve Thirteen Fourteen'
    STDIN.puts 'Fifteen'
    STDIN.puts 'Sixteen!'
    a = nil
    Timeout::timeout(1){ a = Entropy.user(Time.now.to_f.to_s) }
    assert_equal 0, Stub.count
    assert_equal 64, a.length
    min, max = a.minmax
    assert_equal 0, min
    assert_equal 15, max
    assert_in_delta 480, a.inject(0,:+), 66
    wa = a.to(:word)
    assert_equal 0, wa=~/^\w+$/
    qa = a.to(:qgraph)
    assert_equal 0, qa=~/^[[:graph:]]+$/
    qa.pad!(40)
    assert_equal 0, qa=~/^[[:graph:]]{40}$/
  end

  def test_002_entropy_redundant
    STDIN.puts 'One Two Three Four Five'
    STDIN.puts 'Six Seven Eight Nine Ten'
    STDIN.puts 'Eleven Twelve Thirteen Fourteen'
    STDIN.puts 'Fifteen'
    STDIN.puts 'Sixteen!'
    a = nil
    Timeout::timeout(1){ a = Entropy.redundant }
    assert_equal 0, Stub.count
    assert_equal 64, a.length
    min, max = a.minmax
    assert_equal 0, min
    assert_equal 15, max
    assert_in_delta 480, a.inject(0,:+), 66
    wa = a.to(:word)
    assert_equal 0, wa=~/^\w+$/
    qa = a.to(:qgraph)
    assert_equal 0, qa=~/^[[:graph:]]+$/
    qa.pad!(40)
    assert_equal 0, qa=~/^[[:graph:]]{40}$/
  end

end
