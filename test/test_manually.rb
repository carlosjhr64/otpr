require 'tmpdir'
require 'rainbow'

TMPDIR     = Dir.mktmpdir
CONFIGDIR  = File.join TMPDIR,    '.config'
CACHEDIR   = File.join TMPDIR,    '.cache'
LOCALDIR   = File.join TMPDIR,    '.local'
DATADIR    = File.join TMPDIR,    '.local/share'

ENV['HOME'] = TMPDIR
Dir.mkdir CONFIGDIR
Dir.mkdir CACHEDIR
Dir.mkdir LOCALDIR
Dir.mkdir DATADIR

def continue?
  return if STDIN.gets.strip == 'Y'
  puts 'Bad!'.color(:red)
  exit 1 # test not completed
end

puts 'These are user interaction tests.'
puts "I'll let you now what the main test is but flunk on any problems you see."
print 'Ready(Y/n)? '
continue?
puts 'Going to test the clear option.'
puts 'When creating a record, say pin 123, does the screen clear?'
puts 'Starting...'
system('ruby -I ./lib ./bin/otpr --create --clear')
print 'Did the screen clear(Y/n)? '
continue?
puts 'Going to test the no-echo option.'
puts "When reading a record of said pin 123, is standard-in's echo off?"
puts 'Starting...'
system('ruby -I ./lib ./bin/otpr --read --no-echo')
print 'Was echo off(Y/n)? '
continue?
print 'BTW, did you get the secret back(Y/n)? '
continue?
puts 'Going to test update on pin 123 in random mode.'
puts "You'll be asked to supply random words for entropy."
puts "The generated secret should be a qgraph of length 40."
system('ruby -I ./lib ./bin/otpr --update --random')
print 'Pass(Y/n)? '
continue?
puts 'Now going to set batch mode, clear, and no-echo.'
puts 'Just blindly enter 123, and it should clear and show the previous secret.'
system('ruby -I ./lib ./bin/otpr --read --batch --clear --no-echo')
print 'So all you see now is the secret... right? '
continue?
print 'One last chance to flunk.  Pass?(Y/n) '
continue?

puts 'Good!'.color(:green)
