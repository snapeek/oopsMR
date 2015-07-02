require "./nlpir"
require "./sad_panda"
require "pry"

class Entity15
  include Nlpir
  @@od_positive = nil
  @@od_negative = nil
  @@people = nil
  @@event = nil
  @@content = nil
  @@sad_panda = nil

  def initialize
    nlpir_init(UTF8_CODE)
    self.class._load_mappings if !@@event
  end

  attr_accessor :str, :str_ary, :str_proced, :csv_line

  def pick(str)
    @str = str
    @str_ary = text_proc(str, 0).split(' ').select{|e| e}
    @str_proced = text_proc(str, 1)
    pick_up
  end

  def pick_up
    @csv_line = []
    pick_ori
    pick_content
    pick_envent
    pick_people
    pick_np
  end

  def pick_ori
    csv_line << str
  end

  def pick_content
    ary = @@content[:content] & str_ary
    if ary.count > 0
      csv_line << 1
      csv_line << ary.join(' ')
    else
      csv_line << 0
      csv_line << nil
    end
  end

  def pick_envent
    ary = @@event[:envent] & str_ary
    if ary.count > 0
      csv_line << 1
      csv_line << ary.join(' ')
    else
      csv_line << 0
      csv_line << nil
    end
  end

  def pick_people
    ary = []
    @@people[:envent].each do |people, pary|
      ary += (pary & str_ary)
    end
    if ary.count > 0
      csv_line << 1
      csv_line << ary.join(' ')
    else
      csv_line << 0
      csv_line << nil
    end    
  end

  def pick_np
    ary = @@sad_panda.start(str_proced)
    csv_line << ary[0]
    csv_line << ary[2..3].join(' ')
  end

  private
 
  def self._load_mappings
    data_root = File.expand_path('../dict', __FILE__)
    @@od_positive = YAML::load(File.read("#{data_root}/od.positive.yml"))
    @@od_negative = YAML::load(File.read("#{data_root}/od.negative.yml"))
    @@people = YAML::load(File.read("#{data_root}/people.yml"))
    @@event = YAML::load(File.read("#{data_root}/event.yml"))
    @@content = YAML::load(File.read("#{data_root}/content.yml"))
    @@sad_panda = SadPanda.new
  end

end
e = Entity15.new
binding.pry