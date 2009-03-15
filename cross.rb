#!/usr/bin/env ruby

require 'optparse'

def read_freq(fin)
  fin.readline # skip first line
  fin.map do |l| 
    s = l.split(",")
    [s[0].strip, s[1].to_i]
  end
end

ntop = 0

OptionParser.new do |opts|
  opts.on("-n", "--ntop [N]", "number of base verbs") do |n|
    ntop = n.to_i
  end
end.parse!

base   = read_freq(open(ARGV[0])).map {|p| p[0] }[0, ntop]
source = read_freq(open(ARGV[1]))

total = 0
cover = 0

source.each do |p|
  total += p[1]
  cover += p[1] if base.include?(p[0])
end

p cover.to_f/total.to_f
