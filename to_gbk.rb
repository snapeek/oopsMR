require 'pry'
require 'optparse'  
require 'CSV'  

ARGV.each do |file|
  CSV.open(file, "r") do |csv|
    CSV.open(file.gsub('.csv', '_gbk.csv'), "wb") do |csvw|
      while line = csv.readline
        csvw << line.map { |str| str.to_s.encode('gbk','utf-8',{:invalid => :replace, :undef => :replace, :replace => '?'}) }
      end
    end
  end
end