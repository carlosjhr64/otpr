require 'date'

version0 = `ruby -I ./lib ./bin/otpr -v`.strip
version1 = `pwd`.strip.split(/-/).pop
raise "Inconsistent version number, #{version0} != #{version1}" unless version0 == version1

Gem::Specification.new do |s|
  s.name        = 'otpr'
  s.version     = version0
  s.date        = Date.today.to_s
  s.summary     = "Ruby One Time Pass Pad"
  s.description = "Store your master password in google cloud storage."
  s.authors     = ["Carlos Hernandez"]
  s.email       = 'carlosjhr64@gmail.com'
  s.files       = ["lib/otpr.rb"]
  s.executables	<< "otpr"
  s.homepage    = 'https://github.com/carlosjhr64/otpr'
end
