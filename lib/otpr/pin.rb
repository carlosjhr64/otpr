module OTPR
  module Pin
    def self.gets(l=CONFIG[:pin])
      pin = pin0 = ''
      until pin.length == l and pin == pin0
        pin = pin0
        pin0 = ''
        until pin0.length == l
          print 'Enter Pin: '
          pin0 = STDIN.gets.strip
          unless pin0.length==l
            puts "Pin needs to be #{l} characters."
          pin = '' # Ensure that user repeats the pin correctly.
          end
        end
        puts "Now repeat the pin." unless pin == pin0
      end
      puts pin
    end
  end
end
