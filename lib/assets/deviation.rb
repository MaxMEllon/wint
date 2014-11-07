class Deviation
  attr_reader :data, :func, :dev_val

  def initialize(data)
    @data = data
    @func = LinearRegression.new(@data.map {|d| d[:x]}, @data.map {|d| d[:y]})

    # 点と直線の距離
    # y = ax + b => ax - y + b = 0
    # (ax - y + b) / sqrt(a^2 + (-1)^2)
    distance = @data.map {|d| get_distance(d[:x], d[:y])}
    @ave = distance.inject(:+) / distance.size
    @std_dev = Math.sqrt(distance.map {|d| (d-@ave)**2}.inject(:+) / distance.size) # 標準偏差
    @dev_val = distance.map {|d| ((d-@ave) / @std_dev)*10 + 50}  # 偏差値
  end

  def get_distance(x, y)
    (@func.a*x - y + @func.b) / Math.sqrt(@func.a**2 + 1)
  end

  def get_deviation_value(x, y)
    ((get_distance(x, y) - @ave) / @std_dev)*10 + 50
  end

  def get_deviation_degree(x, y)
    get_deviation_value(x, y) - 50
  end

  def regression_data
    [{x: @data.first[:x], y: @func.val(@data.first[:x])}, {x: @data.last[:x], y: @func.val(@data.last[:x])}]
  end
end

