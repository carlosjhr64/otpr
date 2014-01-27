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

COMMAND = 'ruby -I ./lib ./bin/otpr -t'

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
puts 'When creating a record, say pin asdfj, does the screen clear?'
puts 'Starting...'
system("#{COMMAND} --create --clear")
print 'Did the screen clear(Y/n)? '
continue?
puts 'Going to test the no-echo option.'
puts "When reading a record of said pin asdfj, is standard-in's echo off?"
puts 'Starting...'
system("#{COMMAND} --read --no-echo")
print 'Was echo off(Y/n)? '
continue?
print 'BTW, did you get the secret back(Y/n)? '
continue?
puts 'Going to test update on pin asdfj in random mode.'
puts "You'll be asked to supply random words for entropy."
puts "The generated secret should be a qgraph of length 40."
system("#{COMMAND} --update --random")
print 'Pass(Y/n)? '
continue?
puts 'Now going to set batch mode, clear, and no-echo.'
puts 'Just blindly enter asdfj, and it should clear and show the previous secret.'
system("#{COMMAND} --read --batch --clear --no-echo")
print 'So all you see now is the secret... right(Y/n)? '
continue?
print 'One last chance to flunk.  Pass?(Y/n) '
continue?

puts 'Good!'.color(:green)
