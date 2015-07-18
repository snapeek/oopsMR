require 'typhoeus'
require 'pry'
files = Dir.glob("/Users/karma/Downloads/weixin0717/*.csv")

def post_csv(file)
  file = Typhoeus.post(
    "http://staging.wenjuanba.com:4567/sent",
    body: {
      encode: 'gbk',
      poc: "s",
      file: File.open(file, "r")
    }
  )

end
f = files.first
binding.pry
files.each { |f|  post_csv(f)}