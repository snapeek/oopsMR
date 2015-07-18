require 'typhoeus'
require 'pry'
files = Dir.glob("/Users/karma/Downloads/weixin0717/*.csv")

def post_csv(file)
  file = Typhoeus.post(
    "http://staging.wenjuanba.com:3000/sent",
    body: {
      encode: 'gbk',
      poc: "s",
      file: File.open(file, "r")
    }
  )

end


files.each do |f| 
  nf = post_csv(f)
  f.gsub('Downloads', 'Downloads/new')
  File.open(f.gsub('.csv', '_n.csv'), 'w') do |ff|
    binding.pry
    ff.write nf.body
  end
end