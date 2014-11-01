module GraphGenerator
  def scatter_line(data)
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.title text: "コードの行数と得点"
      f.xAxis title: {text: "得点", style: {"font-size" => "16px"}}
      f.yAxis title: {text: "行数", style: {"font-size" => "16px"}}
      f.series data: data, type: 'scatter'
      f.tooltip headerFormat: "<b>{point.key}</b><br />", pointFormat: "score : {point.x}<br />line : {point.y}<br />"
    end
  end

  module_function :scatter_line
end

