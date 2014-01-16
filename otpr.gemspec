Gem::Specification.new do |s|

  s.name     = 'otpr'
  s.version  = '2.0.0'

  s.homepage = 'https://github.com/carlosjhr64/otpr'

  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2014-01-16'
  s.licenses = ['MIT']

  s.description = <<DESCRIPTION
Use short pins to access your long passwords.
DESCRIPTION

  s.summary = <<SUMMARY
Use short pins to access your long passwords.
SUMMARY

  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options     = ["--main", "README.rdoc"]

  s.require_paths = ["lib"]
  s.files = %w(
ANALYSIS.txt
README.rdoc
TODO.txt
bin/otpr
config/config.json
lib/otpr.rb
lib/otpr/config.rb
lib/otpr/entropy.rb
lib/otpr/error.rb
lib/otpr/key.rb
lib/otpr/otpr.rb
lib/otpr/pin.rb
lib/otpr/version.rb
otpr.gemspec
  )
  s.executables << 'otpr'
  s.add_runtime_dependency 'base_convert', '~> 0.0', '>= 0.0.1'

end
