# Stadard Library
require 'open-uri'
require 'digest'
require 'tmpdir'
require 'securerandom'

# Gems
require 'test/unit'
require 'base_convert'
require 'rainbow'

# Require support libraries
require 'otpr/config'
require 'otpr/error'
require 'otpr/entropy'
require 'otpr/key'

# Test rigs...
ZIN  = Dir.mktmpdir
ZANG = Dir.mktmpdir

# THE LIBRARY FILE BEING TESTED
require 'otpr/otpr'

class Test_Otpr < Test::Unit::TestCase
  include OTPR
  CONFIG[:test_mode] = true

  def test_001_initialize
    assert_nothing_raised(Exception){Otpr.new('A_Pin', ZIN, ZANG)}
    assert_raise(Error){Otpr.new('A_Pin', ZIN, '/no-such-dir')}
    assert_raise(Error){Otpr.new('A_Pin', '/dir-not-here', ZANG)}
  end

  def test_002_attributes
    otpr = Otpr.new('A_Pin', ZIN, ZANG)

    salt = File.read("#{ZIN}/salt") + File.read("#{ZANG}/salt")
    assert_equal salt, otpr.salt

    digest = Digest::SHA512.digest('A_Pin'+salt)
    assert_equal digest, otpr.key

    chksum = BaseConvert.new(:hex, :word).convert(Digest::MD5.hexdigest('A_Pin'+salt))
    assert_equal File.join(ZIN, chksum),  otpr.zin
    assert_equal File.join(ZANG, chksum), otpr.zang
  end

  def test_003_exist
    otpr = Otpr.new('A_Pin', ZIN, ZANG)

    refute otpr.exist?
    refute otpr.inconsistent?

    system("touch #{otpr.zin}")
    refute otpr.exist?
    assert otpr.inconsistent?
    system("rm #{otpr.zin}")
    refute otpr.inconsistent?

    system("touch #{otpr.zang}")
    refute otpr.exist?
    assert otpr.inconsistent?
    system("rm #{otpr.zang}")
    refute otpr.inconsistent?

    system("touch #{otpr.zin}")
    system("touch #{otpr.zang}")
    assert otpr.exist?
    refute otpr.inconsistent?
    system("rm #{otpr.zin}")
    system("rm #{otpr.zang}")
    refute otpr.exist?
    refute otpr.inconsistent?
  end

  def test_004_delete
    otpr = Otpr.new('A_Passphrase', ZIN, ZANG)

    refute otpr.exist? # just sanity check
    refute otpr.inconsistent?

    system("touch #{otpr.zin}")
    system("touch #{otpr.zang}")
    assert system("test -e #{otpr.zin}")
    assert system("test -e #{otpr.zang}")
    assert otpr.exist?
    refute otpr.inconsistent?
    otpr.delete
    refute otpr.exist?
    refute otpr.inconsistent?
    refute system("test -e #{otpr.zin}")
    refute system("test -e #{otpr.zang}")

    system("touch #{otpr.zin}")
    assert system("test -e #{otpr.zin}")
    refute system("test -e #{otpr.zang}")
    refute otpr.exist?
    assert otpr.inconsistent?
    otpr.delete
    refute otpr.exist?
    refute otpr.inconsistent?
    refute system("test -e #{otpr.zin}")
    refute system("test -e #{otpr.zang}")
   
    system("touch #{otpr.zang}")
    refute system("test -e #{otpr.zin}")
    assert system("test -e #{otpr.zang}")
    refute otpr.exist?
    assert otpr.inconsistent?
    otpr.delete
    refute otpr.exist?
    refute otpr.inconsistent?
    refute system("test -e #{otpr.zin}")
    refute system("test -e #{otpr.zang}")
  end

  def test_005_pad
    plain = Otpr.pad(' 123 ')
    assert_equal 40, plain.length
    assert_equal '123', plain.strip
    assert_equal 0, plain=~/123/
  end

  def test_006_set_n_get
    otpr = Otpr.new('A_Passphrase', ZIN, ZANG)
    refute otpr.exist? # just sanity check

    # With strip default(which is true)...
    otpr.set(' 123 ')
    assert otpr.exist?
    secret = otpr.get
    assert_equal '123', secret
    otpr.delete
    refute otpr.exist?

    # With strip false...
    otpr.set(' 123 ', false)
    assert otpr.exist?
    secret = otpr.get(false)
    assert_equal ' 123 ', secret
    otpr.delete
    refute otpr.exist?

    # With strip true...
    otpr.set(' 123 ', true)
    assert otpr.exist?
    secret = otpr.get(true)
    assert_equal '123', secret
    # Cleanup
    otpr.delete
    refute otpr.exist?
  end

  def test_007_set
    otpr = Otpr.new('A_Passphrase', ZIN, ZANG)
    refute otpr.exist? # just sanity check
    otpr.set('abc')
    assert otpr.exist?
    yin  = File.read otpr.zin
    refute_nil yin=~/^[[:graph:]]{40}$/
    assert_nil yin=~/['"]/
    assert_nil yin=~/abc/ # although it could happen by chance
    yang = File.read otpr.zang
    # want a way to show yang is just random bits :-??
    refute_equal 'abc', yang # at least it's not abc.
    assert_equal 'abc', otpr.get # but from random bits we get abc.
    # Cleanup
    otpr.delete
    refute otpr.exist?
  end
end
