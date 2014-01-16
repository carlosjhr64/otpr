module OTPR
  BITS    = 256
  NIBBLES = 64
  WORDS   = 16
  DIGEST  = Digest::SHA256
  CHKSUM  = Digest::MD5
  BASE    = 16

  CONFIG = {

    # The help text
    :help => <<-HELP,
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

  Modifiers:
  -R --random     Create a random password.
  -b --batch      Turns off interactive mode.
  -l --clear      Clears screen after pin entries.
  -e --echo       # TODO: Also --no-echo.
  -g --regen      Regenerates pad.
  -w --overwrite --no-overwrite.

  -P --pin-validation --no-pin-validation
  -S --secret-validation --no-secret-validation

  Where is the flash drive?:
  --media='/removable-media-directory/'

See `gem man otpr` for more help.
    HELP

    # Default Options
    :random        => false,
    :batch         => false,
    :clear         => false,
    :echo          => true,
    :regen         => false,
    :overwrite     => false,
    # More default Options
    :pin_validation    => true,
    :secret_validation => false,
    :media             => '/media/KINGSTON/',

    # Default Options not defined in help...
    # These keys can be accessed in ~/.config/otpr/config.json

    # commands and urls
    :clear_command => 'clear',
    :random_web    =>
      'http://www.random.org/integers/?num=64&min=0&max=15&col=64&base=10&format=plain&rnd=new',

    # About the pin
    :enter_pin      => 'Pin: ',
    :pin_min        => 0,
    :pin_too_short  => "Pin is too short.",
    :pin_max        => 64,
    :pin_too_long   => "Pin is too long.",
    :pin_accept     => "^[[:graph:]]*$",
    :pin_reject     => "['\"]",
    :pin_not_valid  => "Pin has illegal characters.",
    :repeat_pin     => "Repeat the pin.",

    # About the secret
    :enter_secret      => 'Secret: ',
    :secret_min        => 0,
    :secret_too_short  => "Secret is too short.",
    :secret_max        => 64,
    :secret_too_long   => "Secret is too long.",
    :secret_accept     => "^[[:graph:]]*$",
    :secret_reject     => "['\"]",
    :secret_not_valid  => "Secret has illegal characters.",
    :repeat_secret     => "Repeat secret.",

    # Prompts
    :gibberish_prompt => 'Please randomly type at least $N words of gibberish:',
    :confirm_delete   => 'Delete(Y/n)?: ',
    :confirm_erase    => 'Erase All Pins(Y/n)?: ',
    # What must 'yes' be on confirmations?
    :y => 'Y',

    # Error messages
    :choose_one         => 'Choose one action.',
    :writting           => 'Writting ',
    :media_not_found    => 'Pad directories not found.',
    :no_yin_yang        => 'Pad files not found.',
    :not_bucket_full    => 'Did not get a full bucket.',
    :could_not_set      => 'Could not set secret.',
    :pin_does_not_exist => 'Pin does not exist.',

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
