require 'open3'
require 'tmpdir'

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

# Requires:
#`bash`

H = {}

def _popen(command, lines)
  IO.popen(command, 'w+'){|p|
    lines.each{|line| p.puts line}
    H['stdout'] = (a=p.gets)? a.chomp : a
  }
  H['status'] = $?.exitstatus
end


def _capture3(command)
  stdout, stderr, status = Open3.capture3(command)
  H['status'] = status.exitstatus
  H['stdout'] = stdout.chomp
  H['stderr'] = stderr.chomp
end

def _given(condition)
  case condition
  when /^(\w+)=(\w+)$/
    H[$1]=H[$2]
  when /^(\w+) "([^"]*)"$/
    H[$1] = $2
  when /^system\(([^\(\)]*)\)$/
    system($1)
  else
    raise "Unrecognized Given-Statement"
  end
end

def _when(condition)
  case condition
  when 'run'
    command, arguments = H['command'], H['arguments']
    raise 'Need command and arguments to run' unless command and arguments
    _capture3("#{command} #{arguments}")
  when /^run\(([^\(\)]*)\)$/
    _capture3($1)
  when /^popen\(([^\(\)]*)\)$/
    lines = $1.strip.split(/\s+/)
    command, arguments = H['command'], H['arguments']
    raise 'Need command and arguments to popen' unless command and arguments
    _popen("#{command} #{arguments}", lines)
  else
    raise "Unrecognized When-Statement"
  end
end

def _then(condition)
  case condition
  when /^(\w+)==(\w+)$/
    a, b = H[$1], H[$2]
    raise "#{a}!=#{b}" unless a==b
  when /^(not )?system\(([^\(\)]*)\)$/
    neg, cmd = $1, $2
    ok = system(cmd)
    ok = !ok if neg
    raise "System Call Error" unless ok
  when /^(\w+) (\w+)( not)? "([^"]*)"$/
    key, cmp, negate, expected = $1, $2, $3, $4
    actual = H[key].to_s
    ok = case cmp
    when 'is'
      actual == expected
    when 'matches'
      expected = Regexp.new(expected)
      actual =~ expected
    else
      raise "Unrecognized Comparison Operator"
    end
    ok = !ok if negate
    raise "Got #{actual} for #{key}" unless ok
  else
    raise "Unrecognized Then-Statement"
  end
end

Given /^(\w+) (.*)$/ do |given, condition|
  condition.strip!
  case given
  when 'Given'
    _given(condition)
  when 'When'
    _when(condition)
  when 'Then'
    _then(condition)
  else
    raise "'#{given}' form not defined."
  end
end
