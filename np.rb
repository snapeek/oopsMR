#!/usr/bin/env ruby

require './sad_panda'
require './nlpir'

require 'optparse'
require 'ostruct'
require 'csv'
require 'pry'
require 'timeout'
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
  i = 0
  CSV.open(file, "r") do |csv|
    while line = csv.readline
      i += 1
      begin
        Timeout::timeout(5) {
          ary << [line[0], $s.start(text_proc(line[0]))[0]]
        }
        puts "poc on line #{i}" if i % 1000 == 0
      rescue Timeout::Error
        puts "timeout on line #{i}"
        ary << line[0]
      rescue Exception => e
        binding.pry
        puts "error on line #{i}"
        ary << line[0]
      end
    end
  end
  ary
end

$s = SadPanda.new
nlpir_init(UTF8_CODE)
binding.pry
ARGV.each do |file|
  ary = load_csv(file)
  binding.pry
  to_csv(file.gsub('.csv', "_mr.csv"), ary, false)
end
nlpir_exit()
# p options
# p ARGV