require 'typhoeus'
require 'pry'
files = Dir.glob("/Users/karma/Downloads/weixin0717/*.csv")

def post_csv(file, n =0)
  file = Typhoeus.post(
    "http://staging.wenjuanba.com:3000/sent",
    body: {
      encode: 'gbk',
      poc: "s",
      n: n.to_s,
      file: File.open(file, "r")
    }
  )
end

files.each do |f| 
  saved = f.gsub('Downloads', 'Downloads/new')
  File.open(saved.gsub('.csv', '_n.csv'), 'w') do |ff|
    n = f.include?('articles') ? 1 : 0
    puts saved.split('/').last
    nf = post_csv(f, n)
    binding.pry
    puts "Error " if nf.response_code != 200
    ff.write nf.body
  end
end