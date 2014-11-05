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
      f.yAxis title: axis_style("度数"), allowDecimals: false
      f.series type: "column", name: "度数", data: dataset
      f.legend enabled: false
      f.plotOptions column: histgram_style
    end
  end

  def line_score(data)
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "得点の推移"
      f.xAxis title: axis_style("戦略番号"), allowDecimals: false
      f.yAxis title: axis_style("得点")
      f.series type: "line", name: "得点", data: data
      f.legend enabled: false
    end
  end

  def bar_submits(data)
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "学生毎の戦略数"
      f.xAxis title: axis_style("学籍番号"), categories: data.map {|d| d.first}
      f.yAxis title: axis_style("戦略数"), allowDecimals: false
      f.series type: "bar", name: "戦略数", data: data
      f.legend enabled: false
    end
  end

  def column_submits_per_day(data, start_at)
    column_submits(data, start_at, {title: "日毎の提出数"})
  end

  def column_submits_total(data, start_at)
    column_submits(data, start_at, {title: "累計提出数"})
  end

  private
  def column_submits(data, start_at, attributes = {})
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: attributes[:title]
      f.xAxis title: axis_style("提出日"), type: "datetime", labels: {format: "{value:%m.%d}"}
      f.yAxis title: axis_style("提出数"), allowDecimals: false
      f.series type: "column", name: "提出数", data: data, pointStart: start_at, pointInterval: 1.days
      f.legend enabled: false
    end
  end

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
                  :line_score,
                  :bar_submits,
                  :column_submits_per_day, :column_submits_total, :column_submits,
                  :axis_style, :histgram_style, :calc_histgram
end

