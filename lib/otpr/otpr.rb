module OTPR
  class Otpr
    def initialize(passphrase, yindir, yangdir)
      unless File.exist?(yindir) and File.exist?(yangdir)
        raise Error, :media_not_found
      end
      key   = DIGEST.digest(passphrase)
      @key  = OTPR::Key.new(key)
      xcs   = CHKSUM.hexdigest(passphrase)
      wcs   = BaseConvert.new(SBT, PNT).convert(xcs)
      @zin  = File.join yindir,  wcs
      @zang = File.join yangdir, wcs
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

    def set(plain, s=STRIP)
      if s
        plain = plain.strip
        while plain.length < PPL
          plain+=' '
        end
      end
      encripted = @key.xor(plain)
      yin   = OTPR::Entropy.computer.to(PPT)
      dyin  = DIGEST.digest(yin)
      yang  = OTPR::Key.new(dyin).xor(encripted)
      File.open(@zin,  'w', 0600){|f| f.write yin}
      File.open(@zang, 'w', 0600){|f| f.write yang}
    end

    def get(s=STRIP)
      raise Error, :no_yin_yang unless exist?
      yin   = File.read @zin
      dyin  = DIGEST.digest(yin)
      yang  = File.read @zang
      encripted = OTPR::Key.new(dyin).xor(yang)
      plain = @key.xor(encripted)
      plain.strip! if s
      return plain
    end
  end
end
