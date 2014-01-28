Gem::Specification.new do |s|

  s.name     = 'otpr'
  s.version  = '2.0.1'

  s.homepage = 'https://github.com/carlosjhr64/otpr'

  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2014-01-28'
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
History.txt
README.rdoc
TODO.txt
bin/otpr
config/config.json
examples/assertion_testing
features/assertion.feature
features/edge.feature
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
man/otpr.1
man/otpr.1.html
man/otpr.1.ronn
otpr.gemspec
test/test_config.rb
test/test_entropy.rb
test/test_hard_ones.rb
test/test_helpers.rb
test/test_key.rb
test/test_manually.rb
test/test_otpr.rb
test/test_otpr_salt.rb
test/test_version.rb
  )
  s.executables << 'otpr'
  s.add_runtime_dependency 'help_parser', '~> 1.2', '>= 1.2.0'
  s.add_runtime_dependency 'user_space', '~> 0.3', '>= 0.3.1'
  s.add_runtime_dependency 'base_convert', '~> 0.0', '>= 0.0.1'
  s.add_runtime_dependency 'rainbow', '~> 1.99', '>= 1.99.1'
  s.add_development_dependency 'test-unit', '~> 2.5', '>= 2.5.5'
  s.requirements << 'system: linux/bash'
  s.requirements << 'bash in development: GNU bash, version 4.2.25(1)-release (x86_64-pc-linux-gnu)'
  s.requirements << 'touch in development: touch (GNU coreutils) 8.13'
  s.requirements << 'rm in development: rm (GNU coreutils) 8.13'
  s.requirements << 'mkdir in development: mkdir (GNU coreutils) 8.13'
  s.requirements << 'rmdir in development: rmdir (GNU coreutils) 8.13'

end
