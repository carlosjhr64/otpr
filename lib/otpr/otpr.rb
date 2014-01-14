module OTPR
  class Otpr
    def initialize(passphrase, yindir, yangdir)
      unless File.exist?(yindir) and File.exist?(yangdir)
        Error.raise(:media_not_found)
      end
      xcs   = CHKSUM.hexdigest(passphrase)
      wcs   = BaseConvert.new(:hexadecimal, :word).convert(xcs)
      xdg   = DIGEST.hexdigest(passphrase)
      qdg   = BaseConvert.new(:hexadecimal, :qgraph).convert(xdg)
      @key  = OTPR::Key.new(qdg)
      @zin  = File.join yindir,  wcs
      @zang = File.join yangdir, wcs
    end

    def set(plain)
      encripted = @key.xor(plain)
      yin   = OTPR::Entropy.computer.to(:qgraph)
      yang  = OTPR::Key.new(yin).xor(encripted)
      File.open(@zin,  'w', 0600){|f| f.write yin}
      File.open(@zang, 'w', 0600){|f| f.write yang}
    end

    def get
      unless File.exist?(@zin) and File.exist?(@zang)
        Error.raise(:no_yin_yang)
      end
      yin   = File.read @zin
      yang  = File.read @zang
      encripted = OTPR::Key.new(yin).xor(yang)
      plain = @key.xor(encripted)
      return plain
    end
  end
end
