#!/usr/bin/env ruby
require 'digest/md5'
errors = 0
puts
run = 'ruby -I ./lib ./bin/rotp'
puts "Version(-v):"
puts (out = `#{run} -v`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='09fea378b96141413f5f09444573f0f3')? "OK" : "BAD" && errors+=1
puts
puts
puts "Help(-h):"
puts (out = `#{run} -h`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='b6ede9c0a1d3423f872b16f6373cb452')? "OK" : "BAD" && errors+=1
puts
puts
puts "Help(-H):"
puts (out = `#{run} -H`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='7906ad1076af7ed1221483ac438fbdf6')? "OK" : "BAD" && errors+=1
puts
puts
puts "Oooops!(--caca):"
puts (out = `#{run} --caca 2> ./temp`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='d41d8cd98f00b204e9800998ecf8427e')? "OK" : "BAD" && errors+=1
puts
puts "Output to stderr:"
puts (out = `cat ./temp`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='8ece872087ef86f64be53b7d3279100b')? "OK" : "BAD" && errors+=1
puts
puts
if errors == 0 then
  def ask(question)
    $stdout.puts question
    answer = $stdin.gets.strip
    return answer
  end
  puts "The following requires going live." 
  puts "Will attempt to intiate a pad." 
  puts "Press Ctrl-C to exit at any time to quit." 
  bucket = ask("Google Store Bucket: ")
  padname = ask("Pad Name: ")
  backup = ask("Backup: ")
  password = ask("Password: ")
  akey = ask("Access Key: ")
  skey = ask("Secret Key: ")
  puts (progress = "A")
  IO.popen("ruby -I ./lib ./bin/rotp --strict --init #{bucket} #{padname} #{backup}",'w+') do |pipe|
    puts (progress = "B")
    question = pipe.gets.strip # should ask for password
    break unless question == "Password:"
    puts (progress = "C")
    pipe.puts password
    question = pipe.gets.strip
    break unless question == "Access Key:"
    puts (progress = "D")
    pipe.puts akey
    question = pipe.gets.strip
    break unless question == "Secret Key:"
    puts (progress = "E")
    pipe.puts skey
    puts (progress = "F")
  end
  if !(progress == "F") then
    puts "Could not complete initiation.  Got to step #{progress}"
    errors += 1 
  end
  if errors == 0 then
    puts "Looks like we succeded in initiating our pads."
  end
end
puts "There were #{errors} errors"
