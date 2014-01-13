module OTPR
  BITS    = 256
  NIBBLES = 64
  WORDS   = 16
  DIGEST  = Digest::SHA256
  BASE    = 16

  CONFIG = {
    :pad => '',
    :pin => 7,
    :pwd => 64,
    :gibberish_prompt => 'Please randomly type at least $N words of gibberish:',
    :random_web => 'http://www.random.org/integers/?num=64&min=0&max=15&col=64&base=10&format=plain&rnd=new'
  }
end
