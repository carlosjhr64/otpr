module OTPR
  class Otpr
    def self.salt(dir)
      saltfile = File.join dir, 'salt'
      unless File.exist? saltfile
        STDERR.puts (CONFIG[:writting] + saltfile).color(:green)
        File.open(saltfile, 'w', 0600) do |f|
          f.write Entropy.computer.to(:qgraph).pad!(PPE)
        end
      end
      File.read saltfile
    end

    attr_reader :key, :zin, :zang, :salt
    def initialize(pin, yindir, yangdir)
      unless File.exist?(yindir) and File.exist?(yangdir)
        raise Error, :media_not_found
      end

      @salt  = Otpr.salt(yindir) + Otpr.salt(yangdir)
      digest = DIGEST.digest(pin+@salt)
      @key   = Key.new(digest)

      xcs    = CHKSUM.hexdigest(pin+@salt)
      wcs    = BaseConvert.new(SBT, PNT).convert(xcs)
      @zin   = File.join yindir,  wcs
      @zang  = File.join yangdir, wcs
    end

    def exist?
      File.exist?(@zin) and File.exist?(@zang)
    end

    def inconsistent?
      File.exist?(@zin) ^ File.exist?(@zang)
    end

    def delete
      File.unlink(@zin)  if File.exist?(@zin)
      File.unlink(@zang) if File.exist?(@zang)
    end

    def self.pad(plain)
      plain = plain.strip
      while plain.length < PPE
        plain+=' '
      end
      return plain
    end

    def self.set(zin, zang, encripted)
      yin       = Entropy.computer.to(PPT).pad!(PPE)
      dyin      = DIGEST.digest(yin)
      yang      = Key.new(dyin).xor(encripted)
      File.open(zin,  'w', 0600){|f| f.write yin}
      File.open(zang, 'w', 0600){|f| f.write yang}
    end

    def set(plain, strip=STRIP)
      plain     = Otpr.pad(plain) if strip
      encripted = @key.xor(plain)
      Otpr.set(@zin, @zang, encripted)
    end

    def self.get(zin, zang)
      yin   = File.read zin
      dyin  = DIGEST.digest(yin)
      yang  = File.read zang
      return Key.new(dyin).xor(yang)
    end

    def get(strip=STRIP)
      raise Error, :no_yin_yang unless exist?
      encripted = Otpr.get(@zin, @zang)
      plain = @key.xor(encripted)
      plain.strip! if strip
      return plain
    end
  end
end
