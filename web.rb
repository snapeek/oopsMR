require 'sinatra'
require "pry"
require 'csv'

require './sad_panda'
require './nlpir'
require "./pocsv"
include Nlpir

$s = SadPanda.new
nlpir_init(UTF8_CODE)

configure do
  set :public_folder, "#{File.dirname(__FILE__)}/assets"
  set :views, "#{File.dirname(__FILE__)}/views"
  set :show_exceptions, :after_handler
  set :environment, :production
end

configure :production, :development do
  enable :logging
end

get "/" do
  # @profiles = Profile.all
  erb :form
end

post "/sent" do
  unless params[:file] &&  
      (tempfile = params[:file][:tempfile]) &&  
      (filename = params[:file][:filename])  
    @error = 'No file selected'  
    redirect to('/')
  end
  target = "./files/#{filename}"  
  File.open(target, 'wb') {|f| f.write tempfile.read }
  poc = select_poc(params[:poc], params[:n].to_i)
  csv = load_ori(target, poc)
  new_file_name = to_csv(target ,csv)
  # binding.pry
  send_file(new_file_name, :type => "text/csv")
  #response.headers['content_type'] = "application/octet-stream"
  #attachment(new_file_name)
  #response.write(File.read(new_file_name, 'r'))  
end


def select_poc(poc, n = 0)
  case poc
  when "f"
    ->(line){
      line << text_proc(line[n])
    }
  when "s"
    ->(line){
      line << $s.start(text_proc(line[n]))
    }
  when "g"
    ->(line){
      line << line.map { |str| str.to_s.encode('gbk','utf-8',{:invalid => :replace, :undef => :replace, :replace => ''})}
    }
  end
end