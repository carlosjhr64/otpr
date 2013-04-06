# REQUIRED LIBRARIES
require 'digest/md5'
begin
  require 'crypt_tea' # gem 'crypt-tea','= 1.3.0'
rescue Exception
  # above is what works, but documentation shows this...
  require 'crypt-tea'
end
require 'base_convert'
require 'kconv'
require 'gstore' # gem 'gstore','= 0.2.1'

class OTPR

  # SOME CONFIGURATION
  PINLENGTH = 7
  REQLENGTH = 64

  # WHERE ARE YOU?
  DIRECTORY = File.expand_path('~/.otpr')
  Dir.mkdir(DIRECTORY, 0700) if !File.exist?(DIRECTORY)

  DNEW = ".new"

  BASE = BaseConvert.new(:hexadecimal,:word)

  def self.xor_cipher(key,cipher)
    password = ''
    cipher = cipher.bytes.inject([],:push)
    key = key.bytes.inject([],:push)
    ksize = key.length
    cipher.length.times {|n| password += (cipher[n] ^ key[n.modulo ksize]).chr }
    return password
  end

  begin
    # use this version if available
    require 'securerandom'
    def self.rndstr(n=16)
      SecureRandom.random_bytes(n)
    end
  rescue Exception
    $stderr.puts $!
    $stderr.puts "using rand..."
    def self.rndstr(n=16)
      0.upto(n-1).inject(''){|k,c| k+(rand(256)).chr }
    end
  end

  def self.digest(string)
    BASE.convert(Digest::MD5.hexdigest(string))
  end

  def self.valid_password(password0)
    raise "password must have #{REQLENGTH} characters" unless password0.length == REQLENGTH
  end

  def self.valid_pin(pin0)
    raise "pin must have #{PINLENGTH} characters" unless pin0.length == PINLENGTH
  end

  def self.valid_keys(akey0,skey0)
    raise 'unexpected access key length' unless akey0.length == 20
    raise 'unexpected secret key length' unless skey0.length == 40
  end

  def self.client(akey0,skey0)
    GStore::Client.new( :access_key => akey0, :secret_key => skey0 )
  end

  def self.valid_bucket(akey0,skey0,bucket0)
    namex = Regexp.new("Name\\W+#{bucket0}\\W+Name")
    raise "can't get bucket" unless (OTPR.client(akey0,skey0).list_buckets =~ namex)
  end

  NOT_AVAILABLE = "not available"

  def self.check_backup(backup0)
    if File.exist?( backup0 ) then
      # This would clearly be a mistake by the usesr.
      raise "#{backup0} is not a file" if !File.file?(backup0)
      raise "#{backup0} is not writable" if !File.writable?(backup0)
    end
    dirname = File.dirname(backup0)
    # Might be possible to continue with some funtionality
    raise NOT_AVAILABLE if !File.exist?(dirname)
    # Again, this would clearly be a mistake by the usesr
    raise "#{backup0} directory is not writable" if !File.writable?(dirname)
  end

  def set_backup( backup0 )
    begin
      OTPR.check_backup(backup0)
    rescue Exception
      raise $! unless $!.message == NOT_AVAILABLE
    end
    @backup = backup0
  end

  def set_padname( padname0 )
    raise "bad pad name" unless padname0 =~ /^\w+$/
    @padname = padname0
  end

  def set_bucket( bucket0 )
    raise "bad bucket name" unless bucket0 =~ /^\w+$/
    @bucket = bucket0
  end

  attr_reader	:backup, :bucket, :padname, :password
  def initialize(bucket0,padname0,backup0=nil)
    set_bucket( bucket0 )
    set_padname( padname0 )
    set_backup( backup0 ) if backup0
  end

  def salt
    File.join(@bucket,@padname)
  end

  def cryptkey
    Digest::MD5.digest(salt)
  end

  def padid
    OTPR.digest(cryptkey)
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

  def cipherpad
    "#{padid}.pad"
  end

  def save_akey(akey0)
    File.open(akeypad,'w',0600){|fh| fh.print Crypt::XXTEA.encrypt(cryptkey,akey0) }
  end

  def save_skey(skey0)
    File.open(skeypad,'w',0600){|fh| fh.print Crypt::XXTEA.encrypt(cryptkey,skey0) }
  end

  def mkbucketdir
    dir0 = bucketdir
    Dir.mkdir(dir0, 0700) if !File.exist?(dir0)
  end

  def set_keys(akey0,skey0)
    mkbucketdir
    save_akey(akey0)
    save_skey(skey0)
    @akey, @skey = akey0, skey0
  end

  def initialize_client(akey0,skey0)
    OTPR.valid_keys(akey0,skey0)
    OTPR.valid_bucket(akey0,skey0,@bucket)
    set_keys(akey0,skey0)
  end

  def akey
    @akey ||= Crypt::XXTEA.decrypt(cryptkey, File.read(akeypad))
  end

  def skey
    @skey ||= Crypt::XXTEA.decrypt(cryptkey, File.read(skeypad))
  end

  def client
    OTPR.client(akey,skey)
  end

  def reset_password(password0)
    OTPR.valid_password( password0 )
    key0 = OTPR.rndstr
    key1 = OTPR.xor_cipher(password0[0..(PINLENGTH-1)],key0)
    cipher = Crypt::XXTEA.encrypt(key1,password0)
    # What happens here is if the copy to backup fails,
    # the OTP does not regenerate, but remains effective.
    File.open( @backup+DNEW, 'w', 0600 ){|fh| fh.print cipher} if @backup
    client.put_object(@bucket, cipherpad, :data => cipher)
    File.open(keypad,'w',0600){|fh| fh.print key0 }
    # Now that we know the OTP regenerated,
    # the backup finishes it's transaction.
    File.rename( @backup+DNEW, @backup ) if @backup
    # Not completely failsafe, but
    # keypad is very unlikely to fail.
    return password0
  end

  def new_password(password0)
    OTPR.check_backup(@backup) if @backup
    reset_password(password0)
  end

  def initialize_pad( akey0, skey0, password0 )
    # Need to ensure initiation can write to backup
    OTPR.check_backup(@backup) if @backup
    initialize_client(akey0,skey0)
    reset_password(password0)
  end

  def get_password( pin0 )
    cipher0 = nil
    # assuming backup is the faster read
    if @backup && File.exist?(@backup) then
      cipher0 = File.read(@backup)
    else
      cipher0 = client.get_object(@bucket,cipherpad)
    end
    key0 = File.read(keypad)
    key1 = OTPR.xor_cipher(pin0,key0)
    Crypt::XXTEA.decrypt(key1,cipher0)
  end

  def pin_password( pin0, regenerate=true )
    OTPR.valid_pin(pin0)
    password0 = get_password( pin0 )
    raise "could not get password" unless password0[0..(PINLENGTH-1)] == pin0
    if regenerate then
      begin
        # Reset might fail
        reset_password(password0)
      rescue Exception
        $stderr.puts $!
        # in any case, we have our password
      end
    end
    return password0
  end

end
