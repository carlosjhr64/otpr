module OTPR
  module Pin
    def self.gets(conf={})
      conf.extend Config
      min, max = conf[:pinmin], conf[:pinmax]
      pin, pin0 = '', nil
      # Ensure user can acurately enter and repeat the pin
      until pin == pin0
        pin, pin0, length = pin0, nil, -1
        until length >= min and length <= max and pin0 =~ ACCEPT and !(pin0 =~ REJECT)
          print conf[:enter_pin]
          pin0 = STDIN.gets.strip
          length = pin0.length
          break unless conf[:pin_validation]
          puts conf[:pin_not_valid] if !(pin0 =~ ACCEPT) or (pin0 =~ REJECT)
          puts conf[:pin_too_short] if length < min
          puts conf[:pin_too_long]  if length > max
        end
        puts conf[:pin_repeat] unless pin == pin0
      end
      return pin
    end
  end
end
