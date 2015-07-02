#!/usr/bin/env ruby

require './entity15'

$e = Entity15.new

def load_csv(file)
  ary = []
  CSV.open(file, "r") do |csv|
    while line = csv.readline
      ary << line + $e.pick(line[3])
    end
  end
  ary
end

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
binding.pry
# ARGV.each do |file|
#   ary = load_csv(file)
#   to_csv(file.gsub('.csv', "_mr.csv"), ary, false)
# end