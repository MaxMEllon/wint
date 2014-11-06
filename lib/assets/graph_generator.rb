module GraphGenerator
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
      f.xAxis title: axis_style("偏差値"), categories: dataset.map {|d| d.first}
      f.yAxis title: axis_style("度数"), allowDecimals: false
      f.series type: "column", name: "度数", data: dataset
      f.legend enabled: false
      f.plotOptions column: {pointPadding: 0, groupPadding: 0, shadow: false}
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

  def pie_result(data)
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "各手役の出現数の割合"
      f.series type: "pie", name: "割合", data: data
      f.tooltip pointFormat: "{series.name} : {point.percentage:.2f}%"
    end
  end

  def column_strategies_per_day(data, start_at)
    column_strategies(data, start_at, {title: "日毎の提出数"})
  end

  def column_strategies_total(data, start_at)
    column_strategies(data, start_at, {title: "累計提出数"})
  end

  private
  def column_strategies(data, start_at, attributes = {})
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: attributes[:title]
      f.xAxis title: axis_style("提出日"), type: "datetime", labels: {format: "{value:%m.%d}"}
      f.yAxis title: axis_style("戦略数"), allowDecimals: false
      f.series type: "column", name: "戦略数", data: data, pointStart: start_at, pointInterval: 1.days
      f.legend enabled: false
    end
  end

  def axis_style(text)
    {text: text, style: {"font-size" => "16px"}}
  end

  def calc_histgram(data, func)
    # 点と直線の距離
    # y = ax + b => ax - y + b = 0
    # (ax - y + b) / sqrt(a^2 + (-1)^2)
    distance = data.map {|d| (func.a*d[:x] - d[:y] + func.b) / Math.sqrt(func.a**2 + 1)}

    ave = distance.inject(:+)
    std_dev = Math.sqrt(distance.map {|d| (d-ave)**2}.inject(:+) / distance.size) # 標準偏差
    dev_val = distance.map {|d| ((d-ave) / std_dev)*10 + 50}  # 偏差値
    sum = 5  # 10 / 2
    dataset = []

    9.times do  # 10, 20, ... , 90
      next_sum = sum+10
      dataset << [(sum+next_sum)/2, dev_val.count {|d| (sum..next_sum).include?(d)}]
      sum = next_sum
    end
    dataset
  end

  module_function :scatter_line_with_regression, :histgram_line,
                  :line_score,
                  :bar_submits,
                  :pie_result,
                  :column_strategies_per_day, :column_strategies_total, :column_strategies,
                  :axis_style, :calc_histgram
end

