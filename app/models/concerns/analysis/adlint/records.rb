class Records
  def initialize
    @records = []
  end

  def functions
    @records.select(&:function?)
  end

  def metrix
    @records.select(&:metrix?)
  end

  def metrix_line
    metrix.select { |m| m.metrix_type == 'FN_LINE' }
  end

  def metrix_csub
    metrix.select { |m| m.metrix_type == 'FN_CSUB' }
  end

  def add(record)
    @records << record
  end
end

