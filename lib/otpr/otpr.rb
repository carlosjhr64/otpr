module OTPR
  class Otpr
    def self.digest(passphrase)
      digest = DIGEST.digest(passphrase)
      digest + CHKSUM.digest(digest)
    end

    attr_reader :key, :zin, :zang
    def initialize(passphrase, yindir, yangdir)
      unless File.exist?(yindir) and File.exist?(yangdir)
        raise Error, :media_not_found
      end
      digest = Otpr.digest(passphrase)
      @key   = Key.new(digest)
      xcs    = CHKSUM.hexdigest(passphrase)
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
      while plain.length < PPL
        plain+=' '
      end
      return plain
    end

    def set(plain, strip=STRIP)
      plain     = Otpr.pad(plain) if strip
      encripted = @key.xor(plain)
      yin       = Entropy.computer.to(PPT).pad!(PPL)
      dyin      = Otpr.digest(yin)
      yang      = Key.new(dyin).xor(encripted)
      File.open(@zin,  'w', 0600){|f| f.write yin}
      File.open(@zang, 'w', 0600){|f| f.write yang}
    end

    def get(strip=STRIP)
      raise Error, :no_yin_yang unless exist?
      yin   = File.read @zin
      dyin  = Otpr.digest(yin)
      yang  = File.read @zang
      encripted = Key.new(dyin).xor(yang)
      plain = @key.xor(encripted)
      plain.strip! if strip
      return plain
    end
  end
end
