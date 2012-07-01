# To be run like this:
#	ruby -I ./lib ./test/preliminaries.rb

require 'rotp'

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
errors += 1 unless should_eval_true("ROTP::PINLENGTH==3")
errors += 1 unless should_eval_true("ROTP::MINLENGTH==7")
errors += 1 unless should_eval_true("'#{ROTP::DIRECTORY}'=='/home/#{ENV['USER']}/.rotp'")
errors += 1 unless should_eval_true("File.exist?('#{ROTP::DIRECTORY}')")
errors += 1 unless should_eval_true("!File.world_readable?('#{ROTP::DIRECTORY}')")
errors += 1 unless should_eval_true("!File.world_writable?('#{ROTP::DIRECTORY}')")
errors += 1 unless should_eval_true("ROTP::DNEW=='.new'")
errors += 1 unless should_eval_true("ROTP::BASE.class==BaseConvert")

if errors > 0 then
  puts "There were #{errors} errors in section A."
  exit
end

### SECTION B ###
# Test properties of the xor cipher
errors += 1 unless should_eval_true("ROTP.xor_cipher('abc','xyz') == ROTP.xor_cipher('xyz','abc')")
errors += 1 unless should_eval_true("c = ROTP.xor_cipher('abc','xyz'); 'xyz' == ROTP.xor_cipher('abc',c)")
errors += 1 unless should_eval_true("c = ROTP.xor_cipher('abc','xyz'); 'abc' == ROTP.xor_cipher('xyz',c)")
errors += 1 unless should_eval_true("c = ROTP.xor_cipher('abc','xyz'); (c != 'abc') && (c != 'xyz')")
errors += 1 unless should_eval_true("ROTP.xor_cipher('abc','xyz').length == 3")

if errors > 0 then
  puts "There were #{errors} errors in section B."
  exit
end

### SECTION C ###

# Random string generator
errors += 1 unless should_eval_true("ROTP.rndstr.length == 16")
errors += 1 unless should_eval_true("ROTP.rndstr(7).length == 7")
# not likely to be the same
errors += 1 unless should_eval_true("ROTP.rndstr != ROTP.rndstr")

# ROTP's digest should be entirely \w+ and well behaved
errors += 1 unless should_eval_true("ROTP.digest(ROTP.rndstr)=~/^\\w+$/")
# There is a small estatiscal chance of failure
errors += 1 unless should_eval_true("ROTP.digest(ROTP.rndstr(256))=~/^\\w+$/")
errors += 1 unless should_eval_true("ROTP.digest(ROTP.rndstr(256))=~/\\d/")
errors += 1 unless should_eval_true("ROTP.digest(ROTP.rndstr(256))=~/[A-Z]/")
errors += 1 unless should_eval_true("ROTP.digest(ROTP.rndstr(256))=~/[a-z]/")

if errors > 0 then
  puts "There were #{errors} errors in section C."
  exit
end

### SECTION D ###

begin
  errors += 2 # assume error
  ROTP.valid_password('12345678')
  ROTP.valid_password('1234567')
  errors -= 1
  ROTP.valid_password('123456')
rescue Exception
  errors -= 1
end

begin
  errors += 2 # assume error
  ROTP.valid_pin('123')
  errors -= 1
  ROTP.valid_pin('1234')
rescue Exception
  errors -= 1
end

begin
  ROTP.valid_pin('12')
  errors += 1
rescue Exception
  #
end

begin
  ROTP.valid_keys('12345678901234567890','1234567890123456789012345678901234567890')
rescue Exception
  errors += 1
end

begin
  ROTP.valid_keys('crap','1234567890123456789012345678901234567890')
  errors += 1
rescue Exception
end

begin
  ROTP.valid_keys('12345678901234567890','crap')
  errors += 1
rescue Exception
end

if errors > 0 then
  puts "There were #{errors} errors in section D."
  exit
end

#puts "Some visual inspections:"
#puts "\tROTP.rndstr: #{ROTP.rndstr}"
#puts "\tROTP.digest(ROTP.rndstr): #{ROTP.digest(ROTP.rndstr)}"

#print "Continue(Y/n)? "
#q = $stdin.gets
#if q !~ /n/i then
if true then
  ### SECTION E ###
  rotp = ROTP.new('TheBucket','ThePad')
  errors += 1 unless rotp.bucket=='TheBucket'
  errors += 1 unless rotp.padname=='ThePad'
  begin
    rotp = ROTP.new('Bad.Bucket','ThePad')
    errors += 1
  rescue Exception
    #
  end
  begin
    rotp = ROTP.new('TheBucket','Bad/Pad')
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
    rotp = ROTP.new('TheBucket','ThePad','/tmp/backup.pad')
  rescue Exception
    errors += 1 # available
    puts $!
  end
  begin
    rotp = ROTP.new('TheBucket','ThePad','/tmp')
    errors += 1 # not a writable file
  rescue Exception
    #
  end
  begin
    rotp = ROTP.new('TheBucket','ThePad','/Not/Available')
  rescue Exception
    puts $!
    errors += 1 # although not available, proceed
  end
  begin
    ROTP.check_backup('/Not/Available')
    errors += 1 # not available
  rescue Exception
    errors +=1 unless $!.message == ROTP::NOT_AVAILABLE
  end
  if errors > 0 then
    puts "There were #{errors} errors in section F."
    exit
  end

  ### SECTION G ###

  rotp = ROTP.new('TheBucket','ThePad','/tmp/backup.pad')
  begin
    rotp.set_bucket('Bad/Bucket')
    errors += 1
  rescue Exception
    #
  end
  errors += 1 unless rotp.bucket == 'TheBucket'

  begin
    rotp.set_padname('Bad/Bucket')
    errors += 1
  rescue Exception
    #
  end
  errors += 1 unless rotp.padname == 'ThePad'

  begin
    rotp.set_backup('/temp')
    errors += 1
  rescue Exception
    #
  end
  errors += 1 unless rotp.backup == '/tmp/backup.pad'

  if errors > 0 then
    puts "There were #{errors} errors in section G."
    exit
  end

  ### SECTION H ###
  errors += 1 unless rotp.salt == 'TheBucket/ThePad'
  errors += 1 unless rotp.cryptkey == Digest::MD5.digest('TheBucket/ThePad')
  errors += 1 unless rotp.padid == ROTP::BASE.convert(Digest::MD5.hexdigest(Digest::MD5.digest('TheBucket/ThePad')))
  errors += 1 unless rotp.padid == 'DnacIaqCzvEOeqtRiR2lT'
  errors += 1 unless rotp.bucketdir == "/home/#{ENV['USER']}/.rotp/DnacIaqCzvEOeqtRiR2lT"
  errors += 1 unless rotp.keypad == "/home/#{ENV['USER']}/.rotp/DnacIaqCzvEOeqtRiR2lT/key.pad"
  errors += 1 unless rotp.akeypad == "/home/#{ENV['USER']}/.rotp/DnacIaqCzvEOeqtRiR2lT/akey.pad"
  errors += 1 unless rotp.skeypad == "/home/#{ENV['USER']}/.rotp/DnacIaqCzvEOeqtRiR2lT/skey.pad"
  errors += 1 unless rotp.cipherpad == "DnacIaqCzvEOeqtRiR2lT.pad"
  if errors > 0 then
    puts "There were #{errors} errors in section H."
    exit
  end

  ### SECTION I ###
  system("rm -rf /home/#{ENV['USER']}/.rotp/DnacIaqCzvEOeqtRiR2lT")
  if File.exist?('rotp.bucketdir') then
    errors += 1.0
  else
    rotp.mkbucketdir
    if File.exist?(rotp.bucketdir) then
      if File.exist?("/home/#{ENV['USER']}/.rotp/DnacIaqCzvEOeqtRiR2lT")
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
    rotp.save_akey('12345678901234567890')
    rotp.save_skey('1234567890123456789012345678901234567890')
    errors += 1 unless rotp.akey == '12345678901234567890'
    errors += 1 unless rotp.skey == '1234567890123456789012345678901234567890'
    rotp.set_keys('cat','dog')
    errors += 1 unless rotp.akey == 'cat'
    errors += 1 unless rotp.skey == 'dog'
  rescue Exception
    puts $!
    errors += 1
  end
  if errors > 0 then
    puts "There were #{errors} errors in section J."
    exit
  end
  puts "Errors J: #{errors}"
  exit

end

puts "There were #{errors} errors."
