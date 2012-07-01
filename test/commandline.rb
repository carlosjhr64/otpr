#!/usr/bin/env ruby
require 'digest/md5'
errors = 0
puts
run = 'ruby -I ./lib ./bin/rotp'
puts "Version(-v):"
puts (out = `#{run} -v`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='09fea378b96141413f5f09444573f0f3')? "OK" : (errors+=1) && "BAD"
puts
puts
puts "Help(-h):"
puts (out = `#{run} -h`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='1de727d48b4ee6314c7e225832928af1')? "OK" : (errors+=1) && "BAD"
puts
puts
puts "Help(-H):"
puts (out = `#{run} -H`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='33ea9e59b4d70bfd5bc63baec2640e3b')? "OK" : (errors+=1) && "BAD"
puts
puts
puts "Oooops!(--caca):"
puts (out = `#{run} --caca 2> ./temp`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='d41d8cd98f00b204e9800998ecf8427e')? "OK" : (errors+=1) && "BAD"
puts
puts "Output to stderr:"
puts (out = `cat ./temp`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='8cd9650f2ef167f6b09083e763e07a90')? "OK" : (errors+=1) && "BAD"
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
  IO.popen("ruby -I ./lib ./bin/rotp --init #{bucket} #{padname} #{backup}",'w+') do |pipe|

    puts (progress = "Reponding to access key")
    question = pipe.gets.strip
    break unless question == "Access Key:"
    puts (progress = "puts aceess key")
    pipe.puts akey

    puts (progress = "Reponding to secret key")
    question = pipe.gets.strip
    break unless question == "Secret Key:"
    puts (progress = "puts seecret key")
    pipe.puts skey

    puts (progress = "Reponding to password")
    question = pipe.gets.strip
    break unless question == "Password:"
    puts (progress = "puts password...")
    pipe.puts password

    puts (progress = "Done")

  end
  if !(progress == "Done") then
    puts "Could not complete initiation.  Got to step #{progress}"
    errors += 1 
  end
  if errors == 0 then
    puts "Looks like we succeded in initiating our pads."
  end
end
puts "There were #{errors} errors"
