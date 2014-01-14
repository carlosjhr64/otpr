module OTPR
  module Entropy
    module Convertable
      def to(base_key)
        # Note that xself is always base 16!
        # Not a configurable option here.
        xself = self.map{|r| r.to_s(16)}.join
        BaseConvert.new(:hexadecimal, base_key).convert(xself)
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
      computer = 0.upto(NIBBLES-1).inject([]){|a, i| a<<SecureRandom.random_number(BASE)}
      computer.extend Convertable
      return computer
    end

    def self.user(conf={})
      conf.extend OTPR::Config
      user = [] # Entropy from user
      while (user.length) < WORDS
        puts conf[:gibberish_prompt].gsub(/\$N/, (WORDS - user.length).to_s)
        user += STDIN.gets.strip.split(/\s+/)
        user.uniq!
      end
      user = DIGEST.hexdigest(user.join(' ')).chars.map{|h|h.to_i(BASE)}
      user.extend Convertable
      return user
    end

    def self.redundant
      web = nil
      Thread.new{ web = Entropy.web }
      user = Entropy.user
      computer = Entropy.computer
      redundant = 0.upto(NIBBLES-1).inject([]) do |a, i|
        r = (computer[i] + user[i])%BASE
        r = (r + web[i])%BASE if web
        a<<r
      end
      redundant.extend Convertable
      return redundant
    end
  end
end
