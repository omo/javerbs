#!/usr/bin/env ruby

require 'optparse'

def read_freq(fin)
  fin.readline # skip first line
  fin.inject({}) do |a, l| 
    s = l.split(",")
    a[s[0].strip] = s[1].to_i
    a
  end
end

a = read_freq(open(ARGV[0]))
b = read_freq(open(ARGV[1]))

c = {}
a.each do |ak,av|
  bv = b[ak]
  c[ak] = bv/b.size.to_f - av/a.size.to_f
end

c.map.sort{|a,b| b[1] <=> a[1] }.each { |i| print "#{i[0]},#{i[1]}\n" }
