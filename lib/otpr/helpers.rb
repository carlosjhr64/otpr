module OTPR
module Helpers

def error_message
  msg = $!.message
  msg = (CONFIG[msg.to_sym] || msg).color(:red) unless CONFIG[:test_mode]
  STDERR.puts msg
end

def assert(b, comment)
  unless b # This is a sanity check.
    STDERR.puts (CONFIG[comment] || comment).color(:red)
    exit 76 # ProtocolError: This error really should not be possible.
  end
end

def refute(b, comment)
  assert(!b, comment)
end

def assert_equal(a, b, comment)
  assert(a==b, comment)
end

def ask(question)
  print question unless CONFIG[:batch]
  STDIN.gets.strip
end

def system_clear
  system(CONFIG[:clear_command]) if CONFIG[:clear]
end

def get_pin
  pin = (CONFIG[:batch])? STDIN.gets.chomp : Pin.gets
  system_clear
  return pin
end

def user_secret
  secret = nil
  if CONFIG[:batch]
    secret = STDIN.gets.strip
  else
    options = {
      :enter_pin      => CONFIG[:enter_secret],
      :pin_validation => CONFIG[:secret_validation],
      :pin_min        => CONFIG[:secret_min],
      :pin_too_short  => CONFIG[:secret_too_short],
      :pin_max        => CONFIG[:secret_max],
      :pin_too_long   => CONFIG[:secret_too_long],
      :pin_accept     => CONFIG[:secret_accept],
      :pin_reject     => CONFIG[:secret_reject],
      :pin_not_valid  => CONFIG[:secret_not_valid],
      :repeat_pin     => CONFIG[:repeat_secret],
    }
    secret = Pin.gets(options)
  end
  system_clear
  return secret
end

def computer_random
  random = (CONFIG[:batch])?
    Entropy.computer.to(PPT) :
    Entropy.redundant.to(PPT)
  system_clear
  random.pad!(PPL)
end

def get_secret
  (CONFIG[:random])? computer_random : user_secret
end

def get_salt(dir)
  saltfile = File.join dir, 'salt'
  unless File.exist? saltfile
    STDERR.puts (CONFIG[:writting] + saltfile).color(:green)
    File.open(saltfile, 'w', 0600){|f| f.write Entropy.computer.to(:qgraph)}
  end
  File.read saltfile
end

def delete_files_in_dir(zin, zang)
  Dir.glob(File.join(zin, '*')).each do |filename|
    # Don't know why there would be anything but regular file, but...
    if File.file?(filename)
      File.unlink(filename)
      name = File.basename(filename)
      unless name == 'salt'
        filename2 = File.join(zang, name)
        if File.exist?(filename2)
          File.unlink(filename2)
        else
          # This is an alert for possible problems with the software.
          STDERR.puts "Unpaired key deleted: #{name}".color(:green)
        end
      end
    else
      # This is an alert for possible problems with the software.
      STDERR.puts "Did not delete #{filename}".color(:green)
    end
  end
  zang_glob = Dir.glob(File.join(zang, '*'))
  if zang_glob.length == 0
    # This is an alert for possible problems with the software.
    STDERR.puts "Zang did not have salt.".color(:green)
  elsif zang_glob.length == 1
    salt = zang_glob.shift
    if File.basename(salt) == 'salt'
      File.unlink salt
    else
      # This is an alert for possible problems with the software.
      STDERR.puts "Zang's remaining file is not salt.".color(:green)
    end
  else
    # This is an alert that zang may be housing multiple medias.
    STDERR.puts "Zang has keys not found in Zin.".color(:green)
  end
end

end
end
