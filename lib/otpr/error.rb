module OTPR
  class Error < RuntimeError
    def self.raise(key)
      super Error, (CONFIG[key] || key)
    end
  end
end
