module OTPR
  module Entropy
    def self.web(url=CONFIG[:random_web])
      web = open(url).read.strip.split(/\D+/).select{|n| n=~/^\d+$/}.map{|n| n.to_i}
      raise "Did not get a full bucket." unless web.length == NIBBLES
      return web
    rescue
      STDERR.puts $!.message
      return nil
    end

    def self.computer
      computer = 0.upto(NIBBLES-1).inject([]){|a, i| a<<SecureRandom.random_number(BASE)}
      return computer
    end

    def self.user
      user = [] # Entropy from user
      while (user.length) < WORDS
        puts OTPR::CONFIG[:gibberish_prompt].gsub(/\$N/, (WORDS - user.length).to_s)
        user += STDIN.gets.strip.split(/\s+/)
        user.uniq!
      end
      user = DIGEST.hexdigest(user.join(' ')).chars.map{|h|h.to_i(BASE)}
      return user
    end

    def self.redundant
      web = nil
      Thread.new{ web = Entropy.web }
      user = Entropy.user
      computer = Entropy.computer
      redundant = 0.upto(NIBBLES-1).inject([]) do |a, i|
        r = (computer[i] + user[i])%16
        r = (r + web[i])%16 if web
        a<<r
      end
      return redundant
    end
  end
end
