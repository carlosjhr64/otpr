module OTPR
module Helpers

def error_message(msg = $!.message, color=:red, test_mode=CONFIG[:test_mode])
  msg = msg.to_s
  msg = (CONFIG[msg.to_sym] || msg).color(color) unless test_mode
  STDERR.puts msg
end

def assert(b, comment)
  unless b # This is a sanity check.
    error_message(comment)
    exit 76 # ProtocolError: This error really should not be possible.
  end
end

def refute(b, comment)
  assert(!b, comment)
end

def assert_equal(a, b, comment)
  assert(a==b, comment)
end

def ask(question, batch=CONFIG[:batch])
  STDOUT.print question unless batch
  STDIN.gets.strip
end

def user_pin(conf={})
  conf.extend Config
  accept, reject = Regexp.new(conf[:pin_accept]), Regexp.new(conf[:pin_reject])
  min, max = conf[:pin_min], conf[:pin_max]
  pin, pin0 = '', nil
  # Ensure user can acurately enter and repeat the pin
  until pin == pin0
    pin, pin0, length = pin0, nil, -1
    until (length >= min) and (length <= max) and (pin0 =~ accept) and !(pin0 =~ reject)
      print conf[:enter_pin]
      pin0 = (conf[:echo])? STDIN.gets : STDIN.noecho(&:gets)
      pin0 = (STRIP)? pin0.strip : pin0.chomp
      puts unless conf[:echo]
      length = pin0.length
      break unless conf[:pin_validation]
      puts conf[:pin_not_valid] if !(pin0 =~ accept) or (pin0 =~ reject)
      puts conf[:pin_too_short] if length < min
      puts conf[:pin_too_long]  if length > max
    end
    puts conf[:repeat_pin] unless pin == pin0
  end
  return pin
end

def system_clear
  system(CONFIG[:clear_command]) if CONFIG[:clear]
end

def get_pin
  pin = (CONFIG[:batch])? STDIN.gets.chomp : user_pin
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
    secret = user_pin(options)
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

def delete_pads(zin, zang)
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
          error_message("Unpaired key deleted: #{name}", :green)
        end
      end
    else
      # This is an alert for possible problems with the software.
      error_message("Did not delete: #{filename}", :green)
    end
  end
  zang_glob = Dir.glob(File.join(zang, '*'))
  if zang_glob.length == 0
    # This is an alert for possible problems with the software.
    error_message(:zang_empty0, :green)
  elsif zang_glob.length == 1
    salt = zang_glob.shift
    if File.basename(salt) == 'salt'
      File.unlink salt
    else
      # This is an alert for possible problems with the software.
      error_message(:zang_empty1, :green)
    end
  else
    # This is an alert that zang may be housing multiple medias.
    error_message(:zang_multiple, :green)
  end
end

end
end
