#!/usr/bin/env ruby

require './entity15'

e = Entity15.new

def load_csv(file)
  ary = []
  CSV.open(file, "r") do |csv|
    while line = csv.readline
      ary << line + e.pick(line[3])
    end
  end
  ary
end

ARGV.each do |file|
  ary = load_csv(file)
  to_csv(file.gsub('.csv', "_mr.csv"), ary, false)
end