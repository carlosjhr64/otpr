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

def stdin_gets(conf={})
  conf.extend Config
  pin = (conf[:echo])? STDIN.gets : STDIN.noecho(&:gets)
  (STRIP)? pin.strip : pin.chomp
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
      pin0 = stdin_gets(conf)
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
  pin = (CONFIG[:batch])? stdin_gets : user_pin
  system_clear
  return pin
end

def user_secret
  secret = nil
  if CONFIG[:batch]
    secret = stdin_gets
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
  random.pad!(PPE)
end

def get_secret
  (CONFIG[:random])? computer_random : user_secret
end

def files_in(zin)
  Dir.glob(File.join(zin, '*')).each do |filename|
    # Don't know why there would be anything but regular file, but...
    if File.file?(filename)
      name = File.basename(filename)
      next if name=='salt'
      yield filename, name
    else
      # This is an alert for possible problems with the software.
      error_message("Skipping: #{filename}", :green)
    end
  end
end

def delete_unpaired(zin, zang)
  files_in(zin) do |filename, name|
    filename2 = File.join(zang, name)
    unless File.exist?(filename2)
      File.unlink filename
    end
  end
end

def regen_pads(zin, zang)
  files_in(zin) do |filename, name|
    filename2 = File.join(zang, name)
    if File.exist?(filename2)
      encripted = Otpr.get(filename, filename2)
      Otpr.set(filename, filename2, encripted)
      encripted2 = Otpr.get(filename, filename2)
      assert_equal(encripted, encripted2, :could_not_set)
    else
      # This is an alert for possible problems with the software.
      error_message("Unpaired key: #{name}", :green)
    end
  end
end

def delete_pads(zin, zang)
  files_in(zin) do |filename, name|
    File.unlink(filename)
    filename2 = File.join(zang, name)
    if File.exist?(filename2)
      File.unlink(filename2)
    else
      # This is an alert for possible problems with the software.
      error_message("Unpaired key deleted: #{name}", :green)
    end
  end
  zin_salt = File.join(zin,'salt')
  if File.exist?(zin_salt)
    File.unlink(zin_salt)
  else
    error_message("Media did not have salt.", :green)
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
