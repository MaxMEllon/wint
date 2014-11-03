module GraphGenerator
  def scatter_line_with_regression(data, func)
    regression_data = [{x: data.first[:x], y: func.val(data.first[:x])}, {x: data.last[:x], y: func.val(data.last[:x])}]
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "コードの行数と得点"
      f.xAxis title: {text: "得点", style: {"font-size" => "16px"}}
      f.yAxis title: {text: "行数", style: {"font-size" => "16px"}}
      f.series type: "scatter", name: "散布図", data: data
      f.series type: "line", name: "回帰直線", data: regression_data, marker: {enabled: false}
      f.tooltip headerFormat: "<b>{point.key}</b><br />", pointFormat: "score : {point.x}<br />line : {point.y}<br />"
      f.legend layout: "horizontal"
    end
  end

  module_function :scatter_line_with_regression
end

