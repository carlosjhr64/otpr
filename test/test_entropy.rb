# Standard Libraries
require 'digest'
require 'open-uri'
require 'securerandom'

# Gems
require 'test/unit'
require 'base_convert'

# Rigs...
require 'otpr/config'

# THE LIBRARY FILE BEING TESTED
require 'otpr/entropy'

class Test_Entropy < Test::Unit::TestCase
  include OTPR

  def test_001_paddable
    a = 'a'
    a.extend Entropy::Paddable
    a.z = '#'
    a.pad!(3)
    assert_equal '##a', a
    a.z = '$'
    b = a.pad!(6)
    assert_equal '$$$##a', b
    assert_equal a, b
  end

  def test_002_convertable
    a0 = '123456789ABCDEF0'
    q0 = BaseConvert.new(:hex, :qgraph).convert(a0)
    w0 = BaseConvert.new(:hex, :word).convert(a0)

    a1 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
    a1.extend Entropy::Convertable
    q1 = a1.to(:qgraph)
    w1 = a1.to(:word)

    assert_equal(q0, q1)
    assert_equal('%(zJ:t46mo', q1)

    assert_equal(w0, w1)
    assert_equal('1YtudU73D5k', w1)

    a = BaseConvert.new(:qgraph, :hex).convert(q1)
    assert_equal(a0, a)
    a = BaseConvert.new(:word, :hex).convert(w1)
    assert_equal(a0, a)
  end

  def test_003_web
    a = Entropy.web
    assert_equal NIBBLES, a.length
    assert_equal 64, a.length
    min, max = a.minmax
    # There's a small statistical chance any of these will fail.
    assert_equal 0, min
    assert_equal 15, max
    # 66 ~ 3*Sqrt[480]
    assert_in_delta 480, a.inject(0,:+), 66, 'Small chance of failure'
    qa = a.to(:qgraph)
    wa = a.to(:word)
    assert_equal 0, qa=~/^[[:graph:]]+$/
    assert_equal 0, wa=~/^\w+$/
    qa.pad!(40)
    assert_equal 0, qa=~/^[[:graph:]]{40}$/
  end

  def test_004_computer
    a = Entropy.computer
    assert_equal NIBBLES, a.length
    assert_equal 64, a.length
    min, max = a.minmax
    # There's a small statistical chance any of these will fail.
    assert_equal 0, min
    assert_equal 15, max
    # 66 ~ 3*Sqrt[480]
    assert_in_delta 480, a.inject(0,:+), 66, 'Small chance of failure'
    qa = a.to(:qgraph)
    wa = a.to(:word)
    assert_equal 0, qa=~/^[[:graph:]]+$/
    assert_equal 0, wa=~/^\w+$/
    qa.pad!(40)
    assert_equal 0, qa=~/^[[:graph:]]{40}$/
  end

  def test_005_words
    words = ['A', 'house', 'divided', 'stack', 'of', 'cards.',
     'I', 'ran', 'like', 'Ann', 'Rand.',
     'Be', 'like', 'oil,', 'my', 'goodfella.',
     'Adios!']
    a = Entropy.words(words)
    assert_equal NIBBLES, a.length
    assert_equal 64, a.length
    min, max = a.minmax
    # There's a small statistical chance any of these will fail.
    assert_equal 0, min
    assert_equal 15, max
    # 66 ~ 3*Sqrt[480]
    assert_in_delta 480, a.inject(0,:+), 66, 'Small chance of failure'
    qa = a.to(:qgraph)
    wa = a.to(:word)
    assert_equal 0, qa=~/^[[:graph:]]+$/
    assert_equal 0, wa=~/^\w+$/
    qa.pad!(40)
    assert_equal 0, qa=~/^[[:graph:]]{40}$/
  end

  # TODO: test Entropy.user and test Entropy.redundant
end
