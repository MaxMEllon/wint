module GraphGenerator
  HIST_SEQ_NUM = 9   #=> 間に0が入るため必ず奇数

  def scatter_line_with_regression(data, func)
    regression_data = [{x: data.first[:x], y: func.val(data.first[:x])}, {x: data.last[:x], y: func.val(data.last[:x])}]
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "コードの行数と得点"
      f.xAxis title: axis_style("得点")
      f.yAxis title: axis_style("行数")
      f.series type: "scatter", name: "散布図", data: data
      f.series type: "line", name: "回帰直線", data: regression_data, marker: {enabled: false}
      f.tooltip headerFormat: "<b>{point.key}</b><br />", pointFormat: "score : {point.x}<br />line : {point.y}<br />"
      f.legend layout: "horizontal"
    end
  end

  def histgram_line(data, func)
    dataset = calc_histgram(data, func)
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "ヒストグラム"
      f.xAxis title: axis_style("点と直線の距離"), categories: dataset.map {|d| d.first}
      f.yAxis title: axis_style("度数")
      f.series type: "column", name: "度数", data: dataset
      f.legend enabled: false
      f.plotOptions column: histgram_style
    end
  end

  private
  def axis_style(text)
    {text: text, style: {"font-size" => "16px"}}
  end

  def histgram_style
    #{pointPadding: 0, borderWidth: 0, groupPadding: 0, shadow: false}
    {pointPadding: 0, groupPadding: 0, shadow: false}
  end

  def calc_histgram(data, func)
    # y = ax + b => ax - y + b = 0
    # (ax - y + b) / sqrt(a^2 + (-1)^2)
    distance = data.map {|d| -1*(func.a*d[:x] - d[:y] + func.b) / Math.sqrt(func.a**2 + 1)}
    base = [distance.max.abs, distance.min.abs].max / (HIST_SEQ_NUM / 2)
    sum = base * (HIST_SEQ_NUM / 2) * -1 - base/2
    dataset = []
    HIST_SEQ_NUM.times do
      next_sum = sum+base
      dataset << ["%.2f" % ((sum+next_sum)/2), distance.count {|d| (sum..next_sum).include?(d)}]
      sum = next_sum
    end
    dataset
  end

  module_function :scatter_line_with_regression, :histgram_line,
                  :axis_style, :histgram_style, :calc_histgram
end

