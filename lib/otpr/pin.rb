module OTPR
  module Pin
    def self.gets(conf={})
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
  end
end
