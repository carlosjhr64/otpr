module OTPR

  # Defining Configuration:
  DIGEST  = Digest::SHA512
  CHKSUM  = Digest::MD5
  ENTROPY = 256            # Desired entropy in bits
  PPT     = :qgraph        # Passphrase Type
  PNT     = :word          # Pin Type
  STRIP   = true           # Leading and trailing whitespaces are meaningless?

  # THIS ONE SHOULD NOT BE CHANGED
  # UNLESS ONE IS PREPARED TO CHECK EVERYTHING ELSE
  SBT     = :hex    # Standard Base Type, hexadecimal

  # Computable Configuration:
  # Example values assumes 256 bits of entropy,
  # SHA512 digest, MD5 checksum,
  # :hex standard base type,
  # :qgraph passphrase, and :word pin.
  # Not all constants used (or useful?), but provided for completeness.
  DIGEST_LENGTH = DIGEST.digest('').length        # 64
  CHKSUM_LENGTH = CHKSUM.digest('').length        # 16
  # Base sizes:
  SBS           = BaseConvert::BASE[SBT]          # 16 Standard/Hex Base Size
  PPS           = BaseConvert::BASE[PPT]          # 91 Passphrase Base Size
  PNS           = BaseConvert::BASE[PNT]          # 62 Pin Base Size
  DWS           = 99171                           # Dictionary Size (word count)
  # Conversion constants:
  LG2           = Math.log(2)                     # 0.693...
  SBK           = LG2/Math.log(SBS)               # 0.25
  PPK           = LG2/Math.log(PPS)               # 0.153...
  PNK           = LG2/Math.log(PNS)               # 0.167...
  DWK           = LG2/Math.log(DWS)               # 0.0602...
  # Lengths based on desired entropy:
  PPE           = (1 + PPK*ENTROPY).round         # 40
  PNE           = (1 + PNK*ENTROPY).round         # 44
  DWE           = (1 + DWK*ENTROPY).round         # 16
  # Lengths based on digest length:
  PPD           = (1 + PPK*8*DIGEST_LENGTH).round # 80
  PND           = (1 + PNK*8*DIGEST_LENGTH).round # 87
  DWD           = (1 + DWK*8*DIGEST_LENGTH).round # 32
  # Lengths based on checksum length:
  PPC           = (1 + PPK*8*CHKSUM_LENGTH).round # 21
  PNC           = (1 + PNK*8*CHKSUM_LENGTH).round # 22
  DWC           = (1 + DWK*8*CHKSUM_LENGTH).round # 9
  # Desired entropy in nibbles (for hexadecimal)
  NIBBLES       = ENTROPY/4                       # 64

  CONFIG = {

    # The help text
    :help => <<-HELP,
Long passwords from short pins.

Usage: otpr [options]

Options:
  -v --version
  -h --help
  Actions:
  -c --create  Create a new pin-password pair.
  -r --read    Read a pin's password.
  -u --update  Update a pin with a new password.
  -d --delete  Delete a pin-password pair.
  -s --status  Status of a pin (exists?).
  -C --copy    Copy pin content to a new pin.
  -M --move    Move pin content to a new pin.
  --erase      Deletes all pins.
  --regen-all  Re-encripts all pads.
  --remove-unpaired
  --remove-unpaired-keys
  --remove-unpaired-files
  Modifiers:
  -R --random  Create a random password.
  -b --batch   Turns off interactive mode.
  -l --clear   Clears screen after pin entries.
  -g --regen   Re-encripts pad.
  -e --echo --no-echo.
  -w --overwrite --no-overwrite.
  -P --pin-validation --no-pin-validation
  -V --secret-validation --no-secret-validation
  Show or don't show secret?:
  -S --show-secret --no-show-secret
  Where is the flash drive?:
  --media='/removable-media-directory/'

More help: gem man otpr
    HELP

    # Default Options
    :random        => false,
    :batch         => false,
    :clear         => false,
    :regen         => false,
    :echo          => true,
    :overwrite     => false,
    :pin_validation    => true,
    :secret_validation => true,
    :show_secret       => true,
    :media             => '/media/KINGSTON/',

    # Default Options not defined in help...
    # These keys can be accessed in ~/.config/otpr/config.json

    # commands and urls
    :clear_command => 'clear',
    :random_web    =>
      "http://www.random.org/integers/?num=64&min=0&max=#{SBS-1}&col=64&base=10&format=plain&rnd=new",

    # About the pin
    :enter_pin      => 'Pin: ',
    :pin_min        => 0,
    :pin_too_short  => 'Pin is too short.',
    # The maximum pin length is based on the maximum meaningful entropy.
    # The pin is checked against CHKSUM, so longer pins are just wasteful.
    :pin_max        => PNC,
    :pin_too_long   => 'Pin is too long.',
    :pin_accept     => '^\w*$',
    :pin_reject     => '[_]',
    :pin_not_valid  => 'Pin has illegal characters.',
    :repeat_pin     => 'Repeat the pin.',

    # About the secret
    :enter_secret      => 'Secret: ',
    :secret_min        => 0,
    :secret_too_short  => 'Secret is too short.',
    # Since the encription key is based on the DIGEST,
    # secrets longer than DIGEST_LENGTH cannot be properly
    # covered using simple xor.
    :secret_max        => DIGEST_LENGTH,
    :secret_too_long   => 'Secret is too long.',
    :secret_accept     => '^[[:graph:]]*$',
    :secret_reject     => '[\'"]',
    :secret_not_valid  => 'Secret has illegal characters.',
    :repeat_secret     => 'Repeat secret.',

    # Prompts
    :gibberish_prompt => 'Please randomly type at least $N words of gibberish:',
    :confirm_delete   => 'Delete(Y/n)?: ',
    :confirm_erase    => 'Erase All Pins(Y/n)?: ',
    :confirm_remove_unpaired => 'Are you sure(Y/n)?: ',
    # What must 'yes' be on confirmations?
    :y => 'Y',

    # Error messages
    :choose_one         => 'Choose one action.',
    :writting           => 'Writting ',
    :media_not_found    => 'Media directory not found.',
    :media_not_a_directory => 'Media not a directory.',
    :no_yin_yang        => 'Pad files not found.',
    :not_bucket_full    => 'Did not get a full bucket.',
    :could_not_set      => 'Could not set secret.',
    :could_not_regen    => 'Could not regenerate a pad.',
    :pin_inconsistent   => 'Pin is missing a key.',
    :pin_does_not_exist => 'Pin does not exist.',
    :pin_exist          => 'Pin exist.',
    :zang_empty0        => 'Zang did not have salt.',
    :zang_empty1        => 'Zang last file is not salt.',
    :zang_multiple      => 'Zang has keys not found in Zin.',

    # Status Responses
    :ok           => 'OK',
    :inconsistent => 'INCONSISTENT',
    :not_found    => 'NOT FOUND',
    :cancelled    => 'CANCELLED',

  }

  module Config
    def [](k)
      (self.has_key?(k))? super : CONFIG[k]
    end
  end
end
