#!/usr/bin/env ruby
require 'digest/md5'
errors = 0
puts
run = 'ruby -I ./lib ./bin/otpr'
puts "Version(-v):"
puts (out = `#{run} -v`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='1347633cdf7cdcb2168d61093630d5ae')? "OK" : (errors+=1) && "BAD"
puts
puts
puts "Help(-h):"
puts (out = `#{run} -h`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='e426b83d87a201f41dbfdfec4fdae484')? "OK" : (errors+=1) && "BAD"
puts
puts
puts "Help(-H):"
puts (out = `#{run} -H`)
puts (dg = Digest::MD5.hexdigest(out))
puts (dg=='313323db11d65de44eef761230116ecb')? "OK" : (errors+=1) && "BAD"
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
puts (dg=='cd86e99c4fde7fbd90b2c27cb2a611fa')? "OK" : (errors+=1) && "BAD"
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
  IO.popen("ruby -I ./lib ./bin/otpr --init #{bucket} #{padname} #{backup}",'w+') do |pipe|

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
