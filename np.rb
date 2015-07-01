#!/usr/bin/env ruby

require './sad_panda'
require './nlpir'

require 'optparse'
require 'ostruct'
require 'csv'
require 'pry'
include Nlpir
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

def load_csv(file)
  ary = []
  CSV.open(file, "r") do |csv|
    ary << [csv[0], $s.start(text_proc(csv[0]))[0]]
  end
  ary
end

$s = SadPanda.new
nlpir_init(UTF8_CODE)
binding.pry
ARGV.each do |csv|
  ary = load_csv(csv)
  to_csv(csv.gsub('.csv', "_mr.csv"), ary, false)
end
nlpir_exit()
p options
p ARGV