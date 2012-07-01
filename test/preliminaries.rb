# To be run like this:
#	ruby -I ./lib ./test/preliminaries.rb

require 'otpr'

def should_eval_true(code)
  ret = false
  begin
    ret = eval(code)
    puts "FALSE: #{code}" unless ret
  rescue Exception
    $stderr.puts $!
    puts "ERROR: #{code}"
  end
  return ret
end

errors = 0

### SECTION A ###
# Trivial but ensures it's what I think it is.
errors += 1 unless should_eval_true("OTPR::PINLENGTH==3")
errors += 1 unless should_eval_true("OTPR::MINLENGTH==7")
errors += 1 unless should_eval_true("'#{OTPR::DIRECTORY}'=='/home/#{ENV['USER']}/.otpr'")
errors += 1 unless should_eval_true("File.exist?('#{OTPR::DIRECTORY}')")
errors += 1 unless should_eval_true("!File.world_readable?('#{OTPR::DIRECTORY}')")
errors += 1 unless should_eval_true("!File.world_writable?('#{OTPR::DIRECTORY}')")
errors += 1 unless should_eval_true("OTPR::DNEW=='.new'")
errors += 1 unless should_eval_true("OTPR::BASE.class==BaseConvert")

if errors > 0 then
  puts "There were #{errors} errors in section A."
  exit
end

### SECTION B ###
# Test properties of the xor cipher
errors += 1 unless should_eval_true("OTPR.xor_cipher('abc','xyz') == OTPR.xor_cipher('xyz','abc')")
errors += 1 unless should_eval_true("c = OTPR.xor_cipher('abc','xyz'); 'xyz' == OTPR.xor_cipher('abc',c)")
errors += 1 unless should_eval_true("c = OTPR.xor_cipher('abc','xyz'); 'abc' == OTPR.xor_cipher('xyz',c)")
errors += 1 unless should_eval_true("c = OTPR.xor_cipher('abc','xyz'); (c != 'abc') && (c != 'xyz')")
errors += 1 unless should_eval_true("OTPR.xor_cipher('abc','xyz').length == 3")

if errors > 0 then
  puts "There were #{errors} errors in section B."
  exit
end

### SECTION C ###

# Random string generator
errors += 1 unless should_eval_true("OTPR.rndstr.length == 16")
errors += 1 unless should_eval_true("OTPR.rndstr(7).length == 7")
# not likely to be the same
errors += 1 unless should_eval_true("OTPR.rndstr != OTPR.rndstr")

# OTPR's digest should be entirely \w+ and well behaved
errors += 1 unless should_eval_true("OTPR.digest(OTPR.rndstr)=~/^\\w+$/")
# There is a small estatiscal chance of failure
errors += 1 unless should_eval_true("OTPR.digest(OTPR.rndstr(256))=~/^\\w+$/")
errors += 1 unless should_eval_true("OTPR.digest(OTPR.rndstr(256))=~/\\d/")
errors += 1 unless should_eval_true("OTPR.digest(OTPR.rndstr(256))=~/[A-Z]/")
errors += 1 unless should_eval_true("OTPR.digest(OTPR.rndstr(256))=~/[a-z]/")

if errors > 0 then
  puts "There were #{errors} errors in section C."
  exit
end

### SECTION D ###

begin
  errors += 2 # assume error
  OTPR.valid_password('12345678')
  OTPR.valid_password('1234567')
  errors -= 1
  OTPR.valid_password('123456')
rescue Exception
  errors -= 1
end

begin
  errors += 2 # assume error
  OTPR.valid_pin('123')
  errors -= 1
  OTPR.valid_pin('1234')
rescue Exception
  errors -= 1
end

begin
  OTPR.valid_pin('12')
  errors += 1
rescue Exception
  #
end

begin
  OTPR.valid_keys('12345678901234567890','1234567890123456789012345678901234567890')
rescue Exception
  errors += 1
end

begin
  OTPR.valid_keys('crap','1234567890123456789012345678901234567890')
  errors += 1
rescue Exception
end

begin
  OTPR.valid_keys('12345678901234567890','crap')
  errors += 1
rescue Exception
end

if errors > 0 then
  puts "There were #{errors} errors in section D."
  exit
end

#puts "Some visual inspections:"
#puts "\tOTPR.rndstr: #{OTPR.rndstr}"
#puts "\tOTPR.digest(OTPR.rndstr): #{OTPR.digest(OTPR.rndstr)}"

#print "Continue(Y/n)? "
#q = $stdin.gets
#if q !~ /n/i then
if true then
  ### SECTION E ###
  otpr = OTPR.new('TheBucket','ThePad')
  errors += 1 unless otpr.bucket=='TheBucket'
  errors += 1 unless otpr.padname=='ThePad'
  begin
    otpr = OTPR.new('Bad.Bucket','ThePad')
    errors += 1
  rescue Exception
    #
  end
  begin
    otpr = OTPR.new('TheBucket','Bad/Pad')
    errors += 1
  rescue Exception
    #
  end
  if errors > 0 then
    puts "There were #{errors} errors in section E."
    exit
  end

  ### SECTION F ###
  begin
    otpr = OTPR.new('TheBucket','ThePad','/tmp/backup.pad')
  rescue Exception
    errors += 1 # available
    puts $!
  end
  begin
    otpr = OTPR.new('TheBucket','ThePad','/tmp')
    errors += 1 # not a writable file
  rescue Exception
    #
  end
  begin
    otpr = OTPR.new('TheBucket','ThePad','/Not/Available')
  rescue Exception
    puts $!
    errors += 1 # although not available, proceed
  end
  begin
    OTPR.check_backup('/Not/Available')
    errors += 1 # not available
  rescue Exception
    errors +=1 unless $!.message == OTPR::NOT_AVAILABLE
  end
  if errors > 0 then
    puts "There were #{errors} errors in section F."
    exit
  end

  ### SECTION G ###

  otpr = OTPR.new('TheBucket','ThePad','/tmp/backup.pad')
  begin
    otpr.set_bucket('Bad/Bucket')
    errors += 1
  rescue Exception
    #
  end
  errors += 1 unless otpr.bucket == 'TheBucket'

  begin
    otpr.set_padname('Bad/Bucket')
    errors += 1
  rescue Exception
    #
  end
  errors += 1 unless otpr.padname == 'ThePad'

  begin
    otpr.set_backup('/temp')
    errors += 1
  rescue Exception
    #
  end
  errors += 1 unless otpr.backup == '/tmp/backup.pad'

  if errors > 0 then
    puts "There were #{errors} errors in section G."
    exit
  end

  ### SECTION H ###
  errors += 1 unless otpr.salt == 'TheBucket/ThePad'
  errors += 1 unless otpr.cryptkey == Digest::MD5.digest('TheBucket/ThePad')
  errors += 1 unless otpr.padid == OTPR::BASE.convert(Digest::MD5.hexdigest(Digest::MD5.digest('TheBucket/ThePad')))
  errors += 1 unless otpr.padid == 'DnacIaqCzvEOeqtRiR2lT'
  errors += 1 unless otpr.bucketdir == "/home/#{ENV['USER']}/.otpr/DnacIaqCzvEOeqtRiR2lT"
  errors += 1 unless otpr.keypad == "/home/#{ENV['USER']}/.otpr/DnacIaqCzvEOeqtRiR2lT/key.pad"
  errors += 1 unless otpr.akeypad == "/home/#{ENV['USER']}/.otpr/DnacIaqCzvEOeqtRiR2lT/akey.pad"
  errors += 1 unless otpr.skeypad == "/home/#{ENV['USER']}/.otpr/DnacIaqCzvEOeqtRiR2lT/skey.pad"
  errors += 1 unless otpr.cipherpad == "DnacIaqCzvEOeqtRiR2lT.pad"
  if errors > 0 then
    puts "There were #{errors} errors in section H."
    exit
  end

  ### SECTION I ###
  system("rm -rf /home/#{ENV['USER']}/.otpr/DnacIaqCzvEOeqtRiR2lT")
  if File.exist?('otpr.bucketdir') then
    errors += 1.0
  else
    otpr.mkbucketdir
    if File.exist?(otpr.bucketdir) then
      if File.exist?("/home/#{ENV['USER']}/.otpr/DnacIaqCzvEOeqtRiR2lT")
        # OK
      else
        errors += 1.3
      end
    else
      errors += 1.2
    end
  end
  if errors > 0 then
    puts "There were #{errors} errors in section I."
    exit
  end

  ### SECTION J ###
  begin
    otpr.save_akey('12345678901234567890')
    otpr.save_skey('1234567890123456789012345678901234567890')
    errors += 1 unless otpr.akey == '12345678901234567890'
    errors += 1 unless otpr.skey == '1234567890123456789012345678901234567890'
    otpr.set_keys('cat','dog')
    errors += 1 unless otpr.akey == 'cat'
    errors += 1 unless otpr.skey == 'dog'
  rescue Exception
    puts $!
    errors += 1
  end
  if errors > 0 then
    puts "There were #{errors} errors in section J."
    exit
  end

end

puts "There were #{errors} errors."
