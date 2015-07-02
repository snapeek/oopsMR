require 'nokogiri'
require 'typhoeus'
require 'pry'
require 'ostruct'
require 'optparse'
require 'csv'
  

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


URL = "http://ictclas.nlpir.org/nlpir/index/getAllContentNew.do"
def get_mr(content)
  return [0.0] if content.to_s.length < 1
  html = Typhoeus.post(URL, :body => {
    :type => 'all',
    :content => content.to_s.encode('utf-8','utf-8',{:invalid => :replace, :undef => :replace, :replace => ''})
    })

  jsoned = JSON.parse(html.body)
  dividewords = jsoned['dividewords']
  npp = JSON.parse(jsoned['stnResult'])
  npp['json0']["negativepoint"].to_i
  npp['json0']["polarity"].to_i
  npp['json0']["positivepoint"].to_i
  [npp['json0']["polarity"].to_i]
rescue Exception => e
  binding.pry
  p "-------- error:#{e} ------"
  [0.0]
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

def load_csv(file)
  ary = []
  CSV.open(file, "r") do |csv|
    while line = csv.readline
      ary << [line[0], get_mr(line[0])[0]]
    end
  end
  ary
end

ARGV.each do |file|
  ary = load_csv(file)
  to_csv(file.gsub('.csv', "_mr.csv"), ary, false)
end