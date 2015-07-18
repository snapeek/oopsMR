require 'timeout'
def to_csv(file, rows, title = nil, encode = "utf-8")
  if File.exist?(file)
    file = file.gsub(".csv", "_new.csv")
  end
  CSV.open(file, "wb") do |csv|
    if title.is_a? Array
      csv << title
    elsif title == true
      title = rows.shift
      title << "正负面"
    end
    if encode == "utf-8"
      csv << title if title 
      rows.each do |row| 
        begin
          csv << (block_given? ? yield(row) : row) 
        rescue Exception => e
          puts "Error"
          csv << []
        end
      end
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
    while true
      i += 1
      begin
        line = csv.readline
        break unless line
        Timeout::timeout(5) {
          ary << block.call(line)
        }
        puts "poc on line #{i}" if i % 1000 == 0
      rescue Timeout::Error
        puts "timeout on line #{i}"
        ary << line
      rescue Exception => e
        puts "error on line #{i}"
        ary << line
      end
    end
  end
  ary
end