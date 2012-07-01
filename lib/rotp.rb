# REQUIRED LIBRARIES
require 'digest/md5'
gem 'crypt-tea','= 1.3.0'
begin
  require 'crypt_tea'
rescue Exception
  # above is what works, but documentation shows this...
  require 'crypt-tea'
end
require 'base_convert'
require 'kconv'
gem 'gstore','= 0.2.1'
require 'gstore'

class ROTP

  # SOME CONFIGURATION
  PINLENGTH = 3
  MINLENGTH = 7

  # WHERE ARE YOU?
  DIRECTORY = File.expand_path('~/.rotp')
  Dir.mkdir(DIRECTORY, 0700) if !File.exist?(DIRECTORY)

  BASE = BaseConvert.new(:hexadecimal,:word)

  def self.xor_cypher(key,cypher)
    password = ''
    cypher = cypher.bytes.inject([],:push)
    key = key.bytes.inject([],:push)
    ksize = key.length
    cypher.length.times {|n| password += (cypher[n] ^ key[n.modulo ksize]).chr }
    return password
  end

  def self.digest(string)
    BASE.convert(Digest::MD5.hexdigest(string))
  end

  def self.rndstr(n=16)
    0.upto(n-1).inject(''){|k,c| k+(rand(256)).chr }
  end

  def self.validate(password0)
    length = password0.length
    raise 'password too short!' unless (length == PINLENGTH) || (length >= MINLENGTH)
  end

  def set_backup( backup0, strict=false, quiet=false )
    if backup0 then
      if !File.exist?(backup0) then
        raise "backup not available" if strict
        $stderr.puts "Warning: backup not available" unless quiet
      end
    end
    @backup = backup0
  end

  def set_password( password0 )
    ROTP.validate( password0 )
    @password = password0
  end

  def set_padname( padname0 )
    raise "bad pad name" unless padname0 =~ /^\w+$/
    @padname = padname0
  end

  def set_bucket( bucket0 )
    raise "bad bucket name" unless bucket0 =~ /^\w+$/
    @bucket	= bucket0
  end

  attr_reader	:backup, :bucket, :padname, :password
  def initialize(bucket0,padname0,password0,backup0=nil,strict=false,quiet=false)
    set_bucket( bucket0 )
    set_padname( padname0 )
    set_password( password0 )
    set_backup( backup0, strict, quiet )
  end

  def salt
    File.join(@bucket,@padname)
  end

  def cryptkey
    Digest::MD5.digest(salt)
  end

  def padid
    ROTP.digest(cryptkey)
  end

  def bucketdir
    File.join( DIRECTORY, padid )
  end

  def keypad
    File.join(bucketdir,"key.pad")
  end

  # Access key pad
  def akeypad
    File.join(bucketdir,"akey.pad")
  end

  # Secret key pad
  def skeypad
    File.join(bucketdir,"skey.pad") # secret key
  end

  def cypherpad
    "#{padid}.pad"
  end

  def pin
    @password[0..(PINLENGTH-1)]
  end

  def init(akey0,skey0)
    raise 'need the actual password (not the pin) to init.' unless @password.length > MINLENGTH
    raise 'unexpected access key length' unless akey0.length == 20
    raise 'unexpected secret key length' unless skey0.length == 40
    dir0 = bucketdir
    Dir.mkdir(dir0, 0700) if !File.exist?(dir0)
    # @bucket is not really a secret, but
    # if anybody somehow got to read this directory let's make it hard.
    File.open(akeypad,'w',0600){|fh| fh.print Crypt::XXTEA.encrypt(cryptkey,akey0) }
    File.open(skeypad,'w',0600){|fh| fh.print Crypt::XXTEA.encrypt(cryptkey,skey0) }
  end

  def akey
    Crypt::XXTEA.decrypt(cryptkey, File.read(akeypad))
  end

  def skey
    Crypt::XXTEA.decrypt(cryptkey, File.read(skeypad))
  end

  def client
    GStore::Client.new( :access_key => akey, :secret_key => skey, )
  end

  def reset(password0=@password)
    ROTP.validate( password0 )
    key0 = ROTP.rndstr
    key1 = ROTP.xor_cypher(pin,key0)
    cypher = Crypt::XXTEA.encrypt(key1,password0)
    client.put_object(@bucket, cypherpad, :data => cypher)
    File.open(keypad,'w',0600){|fh| fh.print key0 }
  end

  def get_password
    cypher0 = client.get_object(@bucket,cypherpad)
    key0 = File.read(keypad)
    key1 = ROTP.xor_cypher(pin,key0)
    Crypt::XXTEA.decrypt(key1,cypher0)
  end

  def pin_password
    # pin_password
    password0 = get_password
    raise "could not get password" unless password0[0..(PINLENGTH-1)] == pin
    reset(password0)
  end

end
