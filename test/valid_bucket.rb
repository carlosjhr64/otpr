require 'otpr'
print "Access Key: "
akey = $stdin.gets.strip
print "Secret Key:"
skey = $stdin.gets.strip
print "Bucket: "
bucket = $stdin.gets.strip

puts "List Buckets"
puts OTPR.client(akey,skey).list_buckets
puts "OTPR.valid_bucket"
OTPR.valid_bucket(akey,skey,bucket)
puts "OK!"
