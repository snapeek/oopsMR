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
f = files.first
nf = post_csv(f)
binding.pry
ff=File.new(f.gsub('.csv', '_n.csv'), 'w')
ff.write nf.body
ff.close
files.each { |f|  post_csv(f)}