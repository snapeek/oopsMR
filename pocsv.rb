require 'timeout'
def to_csv(file, rows, title = nil, encode = "utf-8")
  file = file.gsub(".csv", "_new.csv") if File.exist?(file)
  CSV.open(file, "wb") do |csv|
    csv << (rows.shift << "正负面")
    rows.each do |row| 
      csv << row.to_s.encode('utf-8', encode, {
        :invalid => :replace, :undef => :replace, :replace => ''
        })
    end
  end
  file
end

def to_encode
  CSV.open(file, "r") do |csv|
    CSV.open(file.gsub('.csv', '_gbk.csv'), "wb") do |csvw|
      while line = csv.readline
        csvw << line.map { |str| str.to_s.encode('gbk','utf-8',{:invalid => :replace, :undef => :replace, :replace => '?'}) }
      end
    end
  end  
end

def load_ori(file, block, encode = "utf-8")
  ary = []
  i = 0
  CSV.open(file, "r:#{encode}:utf-8") do |csv|
    while i += 1
      begin
        break unless line = csv.readline
        ary << block.call(line)
        puts "poc on line #{i}" if i % 1000 == 0
      rescue Exception => e
        puts "error on line #{i}"
        ary << line
      end
    end
  end
  ary
end