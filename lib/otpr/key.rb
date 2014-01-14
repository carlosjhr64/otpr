module OTPR
  class Key < String
    def initialize(key)
      super
    end

    def xor(cipher, i=-1)
      cipher.bytes.inject(''){|plain, byte| plain+(byte^self.bytes[(i+=1)%length]).chr}
    end
  end
end
