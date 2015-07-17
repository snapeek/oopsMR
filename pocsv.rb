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

def load_ori(file, block)
  ary = []
  i = 0
  CSV.open(file, "r") do |csv|
    while line = csv.readline
      i += 1
      begin
        binding.pry
        Timeout::timeout(5) {
          line.map!{|str| str.to_s.encode('utf-8','utf-8',{:invalid => :replace, :undef => :replace, :replace => ''})}
          ary << block.call(line)
        }
        puts "poc on line #{i}" if i % 5 == 0
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