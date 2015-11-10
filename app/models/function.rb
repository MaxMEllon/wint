class Function
  attr_reader :name, :assignment_count, :records, :variables, :literals

  def initialize(data_arr)
    @variables = []
    @literals = []
    @assignment_count = 0
    @records = {}
    data_arr.each do |line|
      elem = line.split(',')
      case elem.first
      when 'DEF'
        add_variables(elem)
      when 'LIT'
        add_literals(elem)
      when 'ASN'
        @assignment_count += 1
      when 'MET'
        add_records(elem)
      end
    end
  end

  def add_variables(elem)
    @name = elem[7] and return if elem[4] == 'F' # 関数名だった場合
    return if elem[4] == 'M' # マクロ
    @variables << elem[8]
  end

  def add_literals(elem)
    # [行番号, 文字リテラル]
    @literals << [elem[2].to_i, elem[7].to_i]
  end

  def add_records(elem)
    num = elem.last.to_i
    case elem[1]
    when 'FN_STMT'
      @records[:stmt] = num
    when 'FN_UNRC'
      @records[:unrc] = num
    when 'FN_CSUB'
      @records[:csub] = num
    when 'FN_NEST'
      @records[:nest] = num
    when 'FN_CYCM'
      @records[:cycm] = num
    when 'FN_LINE'
      @records[:line] = num
    when 'FN_UNUV'
      @records[:unub] = num
    when 'FN_PATH'
      @records[:path] = num
    end
  end

  def abc_size
    Math.sqrt(@assignment_count**2 + @records[:csub]**2 + @records[:path]**2).round(2)
  end
end

