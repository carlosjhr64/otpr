module OTPR
  BITS    = 256
  NIBBLES = 64
  WORDS   = 16
  DIGEST  = Digest::SHA256
  CHKSUM  = Digest::MD5
  BASE    = 16

  ACCEPT  = /^[[:graph:]]*$/
  REJECT  = /['"]/

  CONFIG = {
    :writting => 'Writting ',

    :clear => false,

    :media => '/media/KINGSTON/',
    :media_not_found => 'Pad directories not found.',

    :pinmin => 0,
    :pin_too_short => "Pin is too short.",

    :pinmax => 64,
    :pin_too_long => "Pin is too long.",

    :pin_not_valid    => "Pin has illegal characters.",
    :secret_not_valid => "Secret has illegal characters.",

    :pin_validation    => true,
    :secret_validation => false,

    :repeat_pin    => "Repeat the pin.",
    :repeat_secret => "Repeat secret.",

    :enter_pin    => 'Pin: ',
    :enter_secret => 'Secret: ',

    :gibberish_prompt => 'Please randomly type at least $N words of gibberish:',

    :random_web =>
      'http://www.random.org/integers/?num=64&min=0&max=15&col=64&base=10&format=plain&rnd=new',
    :not_bucket_full => 'Did not get a full bucket.',

    :no_yin_yang => 'Pad files not found.',

    :could_not_set => 'Could not set secret.',

    :help => <<-HELP
Usage: otpr [options]
Options:
  -v --version
  -h --help
  -i --init   create a new master password
  -s --set    set your own master password
  -b --batch  turns off interative mode
  -c --clear  clears screen after pin entries
  -r --regen  regenerates pads
  --media='/removable-media-directory/'
Notes:
  Defaults can be set in ~/.config/otpr/config.json
    HELP
  }

  module Config
    def [](k)
      (self.has_key?(k))? super : CONFIG[k]
    end
  end
end
