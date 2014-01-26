module OTPR
  module Entropy

    module Paddable
      def z=(z)
        @z = z
      end

      def pad!(min)
        while self.length < min
          self.insert(0, @z)
        end
        self
      end
    end

    module Convertable
      def to(base_key)
        # Note that xself is always base 16!
        # Not a configurable option here.
        xself = self.map{|r| r.to_s(SBS)}.join
        base = BaseConvert.new(SBT, base_key)
        bself = base.convert(xself)
        bself.extend Paddable
        bself.z = base.to_digits.first
        return bself
      end
    end

    def self.web(conf={})
      conf.extend OTPR::Config
      url = conf[:random_web]
      web = open(url).read.strip.split(/\D+/).select{|n| n=~/^\d+$/}.map{|n| n.to_i}
      raise conf[:not_bucket_full] unless web.length == NIBBLES
      web.extend Convertable
      return web
    rescue
      STDERR.puts $!.message
      return nil
    end

    def self.computer
      computer = 0.upto(NIBBLES-1).inject([]){|a, i| a<<SecureRandom.random_number(SBS)}
      computer.extend Convertable
      return computer
    end

    def self.words(words, salt='')
      string = DIGEST.hexdigest(words.join(' ') + salt).chars.map{|h|h.to_i(SBS)}[0..(NIBBLES-1)]
      string.extend Convertable
      return string
    end

    def self.user(salt='', conf={})
      conf.extend OTPR::Config
      words = [] # Entropy from user
      while (words.length) < DWE
        puts conf[:gibberish_prompt].gsub(/\$N/, (DWE - words.length).to_s)
        words += ((conf[:echo])? STDIN.gets : STDIN.noecho(&:gets)).strip.split(/\s+/)
        words.uniq!
      end
      return Entropy.words(words, salt)
    end

    def self.redundant
      web = nil
      Thread.new{ web = Entropy.web }
      # User's list of words salted with Time.now...
      user = Entropy.user(Time.now.to_f.to_s)
      computer = Entropy.computer
      redundant = 0.upto(NIBBLES-1).inject([]) do |a, i|
        r = (computer[i] + user[i])%SBS
        r = (r + web[i])%SBS if web
        a<<r
      end
      redundant.extend Convertable
      return redundant
    end
  end
end
