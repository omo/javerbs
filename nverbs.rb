#!/usr/bin/env ruby

require 'optparse'
require 'stemmer/porter'

class Statistics
  attr_reader :methods, :verbs, :nonverbs, :verb_dict

  NEARLY_SYNTAX = ["<init>", "toString", "equals", "hashCode"].map { |i| i.intern }

  def initialize
    @verb_dict = {}
    @verb_powerhsell = {}

    @methods = Hash.new(0)
    @nsyntaxes = Hash.new(0)
    @properties = Hash.new(0)
    @verbs = Hash.new(0)
    @nonverbs = Hash.new(0)
  end

  def load_verbs(fin)
    fin.map do |line|
      /^\w+/.match(line).to_a[0]
    end.find_all do |w|
      w != nil 
    end.each do |w|
      wintern = w.intern
      @verb_dict[wintern] = wintern
    end
  end

  def load_verbs_powershell(fin)
    fin.each do |line|
      w = line.strip
      unless w.empty?
        wintern = w.intern
        @verb_powerhsell[wintern] = wintern
      end
    end
  end

  def to_verb_normalized(name)
    str = /^[a-z]+/.match(name.to_s).to_a[0]
    str ? (@verb_dict[str.intern] || @verb_dict[str.stem.intern]) : nil
  end

  def put(name)
    if NEARLY_SYNTAX.include? name
      @nsyntaxes[name] += 1
      return
    end

    if /^(get|set|is)\w+/ =~ name.to_s
      @properties[name] += 1
      return 
    end

    @methods[name] += 1

    verb = to_verb_normalized(name)
    if verb
      @verbs[verb] += 1
    else
      @nonverbs[name] += 1
    end
  end

  def report(output)
    verb_keys = @verbs.keys
    verb_ps_keys = @verb_powerhsell.keys
    verb_unusual = verb_keys - verb_ps_keys

    verb_sum  = @verbs.values.inject(0) {|a,i| a+i}
    cover_sum = verb_ps_keys.inject(0) do |a,i| 
      a += verbs[i]
      a
    end

    rep = <<EOF
verb:  #{verb_keys.size}
ps:    #{verb_ps_keys.size}
diff:  #{verb_unusual.size}
ratio: #{((verb_keys.size - verb_unusual.size).to_f/verb_keys.size)*100}
cover: #{(cover_sum.to_f/verb_sum.to_f)*100.to_i}
EOF
    output.print(rep)
  end

end

#
# bootstrap
#
stat = Statistics.new

method_list = nil
command = nil

def print_count(out, hash)
  hash.to_a.sort { |x,y| y[1] <=> x[1] }.each do |entry|
    print "#{entry[0]},#{entry[1]}\n"
  end
end

OptionParser.new do |opts|
  opts.on("-v", "--verb-index [FILE]", "WordNet verb index to load") do |file|
    stat.load_verbs(open(file))
  end
  opts.on("-m", "--method_list [FILE]", "method name list to load") do |file|
    method_list = file
  end
  opts.on("-p", "--psverb-index [FILE]", "verb from powershell cookbook") do |file|
    stat.load_verbs_powershell(open(file))
  end

  opts.on("-c", "--command [COMMAND]", "command to print the stat") do |c|
    command = c
  end
end.parse!

open(method_list).each { |l| stat.put(l.strip.intern) }

case command
when "methods", "verbs", "nonverbs"
  print_count(STDOUT, stat.send(command))
when "report"
  stat.report(STDOUT)
when nil
  raise "no command given"
else
  raise "Command cannot recognize command: #{command}"
end
