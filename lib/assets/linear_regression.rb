class LinearRegression
  attr_reader :a, :b

  def initialize(x, y)
    n = x.size
    # n*Σx^2 - (Σx)^2
    base = n*sigma(multi_data(x, x)) - sigma(x)**2
    base = 1 if base == 0
    # (n*Σxy - Σx*Σy) / base
    @a = (n*sigma(multi_data(x, y)) - sigma(x)*sigma(y)) / base
    # (Σx^2*Σy - Σxy*Σx)
    @b = (sigma(multi_data(x, x))*sigma(y) - sigma(multi_data(x, y))*sigma(x)) / base
  end

  def val(x)
    @a*x + @b
  end

  private
  def sigma(data)
    return 0 if data.blank?
    data.inject(:+)
  end

  def multi_data(a, b)
    a.zip(b).map {|a, b| a * b}
  end
end

