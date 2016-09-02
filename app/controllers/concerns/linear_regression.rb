class LinearRegression
  attr_reader :a, :b

  def initialize(arr_x, arr_y)
    @arr_x = arr_x
    @arr_y = arr_y
    n = @arr_x.size
    # n*Σx^2 - (Σx)^2
    base = n * sigma(multi_data(@arr_x, @arr_x)) - sigma(@arr_x)**2
    base = 1 if base == 0
    # (n*Σxy - Σx*Σy) / base
    @a = (n * sigma(multi_data(@arr_x, @arr_y)) - sigma(@arr_x) * sigma(@arr_y)) / base
    # (Σx^2*Σy - Σxy*Σx)
    @b = (sigma(multi_data(@arr_x, @arr_x)) * sigma(@arr_y) - sigma(multi_data(@arr_x, @arr_y)) * sigma(@arr_x)) / base
  end

  def regression_data
    [{ x: @arr_x.first, y: val(@arr_x.first) }, { x: @arr_x.last, y: val(@arr_x.last) }]
  end

  private

  def sigma(data)
    return 0 if data.blank?
    data.inject(:+)
  end

  def multi_data(arr_a, arr_b)
    arr_a.zip(arr_b).map { |a, b| a * b }
  end

  def val(x)
    @a * x + @b
  end
end

