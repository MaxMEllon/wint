class AdlintRecordBase
  attr_reader :type, :function_name

  def metrix?
    false
  end

  def function?
    false
  end

  def str2arr(str)
    a, b, c = str.split(/\"/)
    return a.split(',') if b.nil?
    elem = c.split(',')
    elem[0] = b
    a.split(',') + elem
  end
end

