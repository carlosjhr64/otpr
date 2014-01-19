Gem::Specification.new do |s|

  s.name     = 'otpr'
  s.version  = '2.0.0'

  s.homepage = 'https://github.com/carlosjhr64/otpr'

  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2014-01-19'
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
features/assertion.feature
features/main.feature
features/options.feature
features/step_definitions/main_steps.rb
lib/otpr.rb
lib/otpr/config.rb
lib/otpr/entropy.rb
lib/otpr/error.rb
lib/otpr/helpers.rb
lib/otpr/key.rb
lib/otpr/otpr.rb
lib/otpr/version.rb
otpr.gemspec
test/test_config.rb
test/test_entropy.rb
test/test_hard_ones.rb
test/test_helpers.rb
test/test_key.rb
test/test_otpr.rb
test/test_version.rb
  )
  s.executables << 'otpr'
  s.add_runtime_dependency 'base_convert', '~> 0.0', '>= 0.0.1'
  s.add_runtime_dependency 'rainbow', '~> 1.99', '>= 1.99.1'
  s.add_development_dependency 'test-unit', '~> 2.5', '>= 2.5.5'
  s.requirements << 'system: linux/bash'
  s.requirements << 'bash in development: GNU bash, version 4.2.25(1)-release (x86_64-pc-linux-gnu)'
  s.requirements << 'touch in development: touch (GNU coreutils) 8.13'
  s.requirements << 'rm in development: rm (GNU coreutils) 8.13'
  s.requirements << 'ln in development: ln (GNU coreutils) 8.13'

end
