# coding: utf-8
require 'fiddle'
require 'fiddle/struct'
require 'fiddle/import'
require 'fileutils'   
include Fiddle::CParser
include Fiddle::Importer

module Nlpir
  NLPIR_FALSE = 0
  NLPIR_TRUE = 1
  POS_MAP_NUMBER = 4
  ICT_POS_MAP_FIRST = 1            #计算所一级标注集
  ICT_POS_MAP_SECOND = 0       #计算所二级标注集
  PKU_POS_MAP_SECOND = 2       #北大二级标注集
  PKU_POS_MAP_FIRST = 3     	#北大一级标注集
  POS_SIZE = 40

  Result_t = struct ['int start','int length',"char  sPOS[#{POS_SIZE}]",'int iPOS',
  		          'int word_ID','int word_type','int weight']
  
  GBK_CODE = 0                                                    #默认支持GBK编码
  UTF8_CODE = GBK_CODE + 1                          #UTF8编码
  BIG5_CODE = GBK_CODE + 2                          #BIG5编码
  GBK_FANTI_CODE = GBK_CODE + 3             #GBK编码，里面包含繁体字

  #提取链接库接口
  libm = Fiddle.dlopen(File.expand_path("../libNLPIR.so", __FILE__))
 
 NLPIR_Init_rb = Fiddle::Function.new(
    libm['NLPIR_Init'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_Exit_rb = Fiddle::Function.new(
    libm['NLPIR_Exit'],
    [],
    Fiddle::TYPE_INT
  )
  NLPIR_ImportUserDict_rb = Fiddle::Function.new(
    libm['NLPIR_ImportUserDict'],
    [Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_ParagraphProcess_rb = Fiddle::Function.new(
    libm['NLPIR_ParagraphProcess'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_INT],
    Fiddle::TYPE_VOIDP
  )
  NLPIR_ParagraphProcessA_rb = Fiddle::Function.new(
    libm['NLPIR_ParagraphProcessA'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_VOIDP
  )
  NLPIR_FileProcess_rb = Fiddle::Function.new(
    libm['NLPIR_FileProcess'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT],
    Fiddle::TYPE_DOUBLE
  )
  NLPIR_GetParagraphProcessAWordCount_rb = Fiddle::Function.new(
    libm['NLPIR_GetParagraphProcessAWordCount'],
    [Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_ParagraphProcessAW_rb = Fiddle::Function.new(
    libm['NLPIR_ParagraphProcessAW'],
    [Fiddle::TYPE_INT,Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_AddUserWord_rb = Fiddle::Function.new(
    libm['NLPIR_AddUserWord'],
    [Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_SaveTheUsrDic_rb = Fiddle::Function.new(
    libm['NLPIR_SaveTheUsrDic'],
    [],
    Fiddle::TYPE_INT
  )
  NLPIR_DelUsrWord_rb = Fiddle::Function.new(
    libm['NLPIR_DelUsrWord'],
    [Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_GetKeyWords_rb = Fiddle::Function.new(
    libm['NLPIR_GetKeyWords'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_INT,Fiddle::TYPE_INT],
    Fiddle::TYPE_VOIDP
  )
  NLPIR_GetFileKeyWords_rb = Fiddle::Function.new(
    libm['NLPIR_GetFileKeyWords'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_INT,Fiddle::TYPE_INT],
    Fiddle::TYPE_VOIDP
  )
  NLPIR_GetNewWords_rb = Fiddle::Function.new(
    libm['NLPIR_GetNewWords'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_INT,Fiddle::TYPE_INT],
    Fiddle::TYPE_VOIDP
  )
  NLPIR_GetFileNewWords_rb = Fiddle::Function.new(
    libm['NLPIR_GetFileNewWords'],
    [Fiddle::TYPE_VOIDP,Fiddle::TYPE_INT,Fiddle::TYPE_INT],
    Fiddle::TYPE_VOIDP
  )
  NLPIR_FingerPrint_rb = Fiddle::Function.new(
    libm['NLPIR_FingerPrint'],
    [Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_LONG
  )
  NLPIR_SetPOSmap_rb = Fiddle::Function.new(
    libm['NLPIR_SetPOSmap'],
    [Fiddle::TYPE_INT],
    Fiddle::TYPE_INT
  )

  NLPIR_NWI_Start_rb = Fiddle::Function.new(
    libm['NLPIR_NWI_Start'],
    [],
    Fiddle::TYPE_INT
  )
  NLPIR_NWI_AddFile_rb = Fiddle::Function.new(
    libm['NLPIR_NWI_AddFile'],
    [Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_NWI_AddMem_rb = Fiddle::Function.new(
    libm['NLPIR_NWI_AddMem'],
    [Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  NLPIR_NWI_Complete_rb = Fiddle::Function.new(
    libm['NLPIR_NWI_Complete'],
    [],
    Fiddle::TYPE_INT
  )
  NLPIR_NWI_GetResult_rb = Fiddle::Function.new(
    libm['NLPIR_NWI_GetResult'],
    [Fiddle::TYPE_INT],
    Fiddle::TYPE_VOIDP
  )
  NLPIR_NWI_Result2UserDict_rb = Fiddle::Function.new(
    libm['NLPIR_NWI_Result2UserDict'],
    [],
    Fiddle::TYPE_VOIDP
  )

  #--函数

  def nlpir_init(encoding=UTF8_CODE) 
    'utf-8' = 'gbk' if encoding == GBK_CODE
    'utf-8' = 'utf-8' if encoding == UTF8_CODE
    'utf-8' = 'big5' if  encoding == BIG5_CODE
    'utf-8' = 'gbk' if encoding == GBK_FANTI_CODE
    NLPIR_Init_rb.call(nil, encoding, nil)
  end

  def nlpir_exit()
    NLPIR_Exit_rb.call()
  end

  def import_userdict(sFilename)
    NLPIR_ImportUserDict_rb.call(sFilename)
  end

  def text_proc(sParagraph, bPOStagged=NLPIR_TRUE)
    NLPIR_ParagraphProcess_rb.call(sParagraph, bPOStagged).to_s.force_encoding('utf-8')
  end

  def text_procA(sParagraph)
    resultCount = NLPIR_GetParagraphProcessAWordCount(sParagraph)
    pResultCount = Fiddle::Pointer.to_ptr(resultCount)
    p = NLPIR_ParagraphProcessA_rb.call(sParagraph, pResultCount.ref.to_i)
    pVecResult = Fiddle::Pointer.new(p.to_i)
    words_list = []
    words_list << Result_t.new(pVecResult)
    for i in 1...resultCount  do
        words_list << Result_t.new(pVecResult += Result_t.size)
    end
    return words_list
  end

  def text_wordcount(sParagraph)
    NLPIR_GetParagraphProcessAWordCount_rb.call(sParagraph)
  end

  def file_proc(sSourceFilename, sResultFilename, bPOStagged=NLPIR_TRUE)
    NLPIR_FileProcess_rb.call(sSourceFilename, sResultFilename, bPOStagged)
  end
  
  def text_procAW(sParagraph)
    free = Fiddle::Function.new(Fiddle::RUBY_FREE, [TYPE_VOIDP], TYPE_VOID)
    resultCount = NLPIR_GetParagraphProcessAWordCount(sParagraph)
    pVecResult = Pointer.malloc(Result_t.size*resultCount,free)
    NLPIR_ParagraphProcessAW_rb.call(resultCount,pVecResult)
    words_list = []
    words_list << Result_t.new(pVecResult)
    for i in 1...resultCount do
        words_list << Result_t.new(pVecResult+=Result_t.size)
    end
    return words_list
  end

  def add_userword(sWord)
    NLPIR_AddUserWord_rb.call(sWord)
  end

  def save_userdict()
    NLPIR_SaveTheUsrDic_rb.call()
  end

  def del_userword(sWord)
    NLPIR_DelUsrWord_rb.call(sWord)
  end

  def text_keywords(sLine, nMaxKeyLimit=50, bWeightOut=NLPIR_FALSE)
    NLPIR_GetKeyWords_rb.call(sLine, nMaxKeyLimit, bWeightOut).to_s.force_encoding('utf-8')
  end

  def file_keywords(sTextFile, nMaxKeyLimit=50, bWeightOut=NLPIR_FALSE)
    line = NLPIR_GetFileKeyWords_rb.call(sTextFile, nMaxKeyLimit, bWeightOut).to_s
    line.force_encoding('gbk')
    line.encode!('utf-8')
  end

  def text_newwords(sLine, nMaxKeyLimit=50, bWeightOut=NLPIR_FALSE)
    NLPIR_GetNewWords_rb.call(sLine, nMaxKeyLimit, bWeightOut).to_s.force_encoding('utf-8')
  end

  def file_newwords(sTextFile, nMaxKeyLimit=50, bWeightOut=NLPIR_FALSE)
    NLPIR_GetFileNewWords_rb.call(sTextFile, nMaxKeyLimit, bWeightOut).to_s.force_encoding('utf-8')
  end

  def text_fingerprint(sLine)
    NLPIR_FingerPrint_rb.call(sLine)
  end

  def setPOSmap(nPOSmap)
    NLPIR_SetPOSmap_rb.call(nPOSmap)
  end

  def NWI_start()
    NLPIR_NWI_Start_rb.call()
  end

  def NWI_addfile(sFilename)
    NLPIR_NWI_AddFile_rb.call(sFilename)
  end

  def NWI_addmem(sFilename)
    NLPIR_NWI_AddMem_rb.call(sFilename)
  end

  def NWI_complete()
    NLPIR_NWI_Complete_rb.call()
  end

  def NWI_result( bWeightOut = NLPIR_FALSE)
    NLPIR_NWI_GetResult_rb.call(bWeightOut)
  end

  def NWI_result2userdict()
    NLPIR_NWI_Result2UserDict_rb.call()
  end
end
