module GraphGenerator
  ##--  scatter
  def scatter_size(deviation, user_data = nil)
    scatter(deviation, user_data, {title: "ファイルサイズと得点", yAxis: "ファイルサイズ", pointFormat: "score : {point.x:.2f}<br />size : {point.y}"})
  end

  def scatter_line(deviation, user_data = nil)
    scatter(deviation, user_data, {title: "コードの行数と得点", yAxis: "行数", pointFormat: "score : {point.x:.2f}<br />line : {point.y}"})
  end

  def scatter_syntax(deviation, user_data = nil)
    scatter(deviation, user_data, {title: "制御構文中の条件の数と得点", yAxis: "制御構文中の条件の数", pointFormat: "score : {point.x:.2f}<br />while/for+if : {point.y}"})
  end

  def scatter_fun(deviation, user_data = nil)
    scatter(deviation, user_data, {title: "関数の定義数と得点", yAxis: "関数の定義数", pointFormat: "score : {point.x:.2f}<br />func_num : {point.y}"})
  end

  def scatter_gzip(deviation, user_data = nil)
    scatter(deviation, user_data, {title: "圧縮率と得点", yAxis: "圧縮率", pointFormat: "score : {point.x:.2f}<br />圧縮率 : {point.y:.1f}%"})
  end

  ##--  histgram
  def histgram(deviation)
    dataset = calc_histgram(deviation)
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "ヒストグラム"
      f.xAxis title: axis_style("偏差値")
      f.yAxis title: axis_style("度数"), allowDecimals: false
      f.series type: "column", name: "度数", data: dataset
      f.legend enabled: false
      f.plotOptions column: {pointPadding: 0, groupPadding: 0, shadow: false}
    end
  end

  def polar_dev(data)
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "乖離度"
      f.chart polar: true
      f.yAxis min: -50, max: 50
      f.xAxis categories: data.map {|d| d[:x]}
      f.series type: "area", name: "乖離度", data: data.map {|d| d[:y]}
      f.tooltip pointFormat: "{series.name} : {point.y:.1f}"
      f.legend enabled: false
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
  def scatter(deviation, user_data = nil, attributes = {})
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: attributes[:title]
      f.xAxis title: axis_style("得点")
      f.yAxis title: axis_style(attributes[:yAxis])
      f.series type: "line", name: "回帰直線", data: deviation.regression_data, marker: {enabled: false}, color: "black"
      if user_data
        f.series type: "scatter", name: "全員のコード", data: deviation.data.map {|d| [d[:x], d[:y]]}, color: "#2F7ED8"
        f.series type: "scatter", name: "あなたのコード", data: user_data, color: "red"
        f.tooltip pointFormat: attributes[:pointFormat]
      else
        f.series type: "scatter", name: "散布図", data: deviation.data, color: "#2F7ED8"
        f.tooltip headerFormat: "<b>{point.key}</b><br />", pointFormat: attributes[:pointFormat]
      end
      f.legend layout: "horizontal"
    end
  end

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

  def calc_histgram(deviation)
    sum = 5  # 10 / 2
    dataset = []
    9.times do  # -40, -30, ... , 0 , ... , 30, 40
      next_sum = sum+10
      dataset << {x: (sum+next_sum)/2 - 50, y: deviation.dev_val.count {|d| (sum..next_sum).include?(d)}}
      sum = next_sum
    end
    dataset
  end

  module_function :scatter, :scatter_size, :scatter_line, :scatter_syntax, :scatter_fun, :scatter_gzip,
                  :histgram, :polar_dev,
                  :line_score, :bar_submits, :pie_result,
                  :column_strategies_per_day, :column_strategies_total, :column_strategies,
                  :axis_style, :calc_histgram
end

