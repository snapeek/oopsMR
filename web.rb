require 'sinatra'
require "pry"
require 'csv'
require 'json'

require './sad_panda'
require './nlpir'
require "./pocsv"
include Nlpir

$s = SadPanda.new
nlpir_init(UTF8_CODE)

configure do
  set :public_folder, "#{File.dirname(__FILE__)}/files"
  set :views, "#{File.dirname(__FILE__)}/views"
  set :show_exceptions, :after_handler
  set :environment, :production
  set :timeout, 2000
end

configure :production, :development do
  enable :logging
end

get "/" do
  @files = Dir.glob("files/*.csv").map { |e| e.gsub('files/', '') }
  erb :form
end

post "/sent" do
  unless ['utf-8', 'gbk'].include? params[:encode]
    @error = '编码必须是 gbk 或者 utf-8'  
    redirect_to('/')
  end
  unless params[:file] &&  
      (tempfile = params[:file][:tempfile]) &&  
      (filename = params[:file][:filename])  
    @error = '没有选择文件'  
    redirect_to('/')
  end
  target = "./files/#{filename}"
  File.open(target, 'wb') {|f| f.write tempfile.read }
  poc = select_poc(params[:poc], params[:n].to_i - 1)
  csv = load_ori(target, poc, params[:encode])
  new_file_name = to_csv(target.gsub(".csv", "_#{params[:poc]}.csv") ,csv)
  send_file(new_file_name, :type => "text/csv", :filename => new_file_name.split('/').last)
end

post "/api/sent" do
  lines = Array(params[:texts])
  poc = select_poc(params[:poc], 0)
  poced = lines.map do |line|
    poc.call([line])
  end
    {:texts => poced}.to_json
end

get "/api/sent" do
  lines = Array(params[:texts])
  poc = select_poc(params[:poc], 0)
  poced = lines.map do |line|
    line = line.match(/^[\u2E80-\u9FFF]+$/).to_s
    poc.call([line])
  end
    {:texts => poced}.to_json
end

def select_poc(poc, n = 0)
  n = n >=0 ? n : 0
  case poc
  when "f"
    ->(line){
      line << text_proc(line[n])
    }
  when "s"
    ->(line){
      line << $s.start(text_proc(line[n]))[0]
    }
  when "g"
    ->(line){
      line.map { |str| str.to_s.encode('utf-8','gbk',{:invalid => :replace, :undef => :replace, :replace => ''})}
    }
  end
end