#!/usr/bin/env ruby

# require './nlpir'
require './sad_panda'


require 'optparse'
require 'ostruct'
require 'csv'
require 'pry'

options = OpenStruct.new

OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options.verbose = v
  end

  opts.on("-e [Encode]", "encode of the file eg utf-8, gbk ") do |e|
    options.encode = e
  end  

end.parse!

def to_csv(file, rows, title = nil, encode = "utf-8")
  if File.exist?(file)
    file = file.gsub(".csv", "_new.csv")
  end
  CSV.open(file, "wb") do |csv|
    if title.is_a? Array
      csv << title
    elsif title == true
      title = rows.shift
    end
    if encode == "utf-8"
      csv << title if title 
      rows.each{ |row| csv << (block_given? ? yield(row) : row) }
    else
      csv << title.map!{|str| str.to_s.encode(encode, 'utf-8',{:invalid => :replace, :undef => :replace, :replace => '?'}) } if title  
      rows.each do |row| 
        if block_given? 
          csv << yield(row).each{|str| str.to_s.encode('gbk','utf-8',{:invalid => :replace, :undef => :replace, :replace => '?'}) }
        else 
          csv << row.each{|str| str.to_s.encode('gbk','utf-8',{:invalid => :replace, :undef => :replace, :replace => '?'}) }
        end 
      end
    end
  end
end

ARGV.each do |csv|
  # to_csv(csv, [[1234, 1234,1234]], false)
end
s = SadPanda.new
binding.pry
p options
p ARGV