module GraphGenerator
  def column_strategies_per_day(league_id)
    league = League.find(league_id)
    data = league.submissions_count_per_day
    strategies_count_charts('日毎の提出数', :column, data, data.keys)
  end

  def line_strategies_total(league_id)
    league = League.find(league_id)
    data = {}
    total = 0
    league.submissions_count_per_day.each do |key, value|
      data[key] = total
      total += value
    end
    strategies_count_charts('累計提出数', :line, data)
  end

  def scatter_abc_size(league_id, strategy_id = nil)
    league = League.includes(players: [{ best: :strategy }, :user]).find(league_id)

    plots = league.best_strategies.map(&:plot_abc_size)
    regression = LinearRegression.new(plots.map { |p| p[:x] }, plots.map { |p| p[:y] })

    unless strategy_id
      return abc_size_charts(plots, regression) do |f|
        f.tooltip headerFormat: '<b>{point.key}</b><br />', pointFormat: format_score('abc size')
      end
    end

    strategy = Strategy.find(strategy_id)
    abc_size_charts(plots, regression) do |f|
      f.series type: :scatter, name: 'あなたのコード', data: [strategy.plot_abc_size], color: 'red'
      f.tooltip pointFormat: format_score('abc size')
    end
  end

  def line_score(player_id)
    player = Player.find(player_id)
    data = player.strategies.map { |s| [s.number, s.score] }
    create_charts do |f|
      f.title text: '得点の推移'
      f.xAxis title: axis_style('戦略番号'), allowDecimals: false
      f.yAxis title: axis_style('得点')
      f.series type: 'line', name: '得点', data: data
    end
  end

  def bar_submits(league_id)
    players = League.find(league_id).players
    data = players.map { |p| [p.user.snum, p.strategies.count] }
    create_charts do |f|
      f.title text: '学生毎の戦略数'
      f.xAxis title: axis_style('学籍番号'), categories: data.map(&:first)
      f.yAxis title: axis_style('戦略数'), allowDecimals: false
      f.series type: :bar, name: '戦略数', data: data
    end
  end

  private

  def create_charts
    LazyHighCharts::HighChart.new(:graph) do |f|
      f.legend enabled: false
    end.tap do |charts|
      yield charts if block_given?
    end
  end

  def abc_size_charts(plots, regression)
    create_charts do |f|
      f.title text: '最大ABCサイズと得点'

      f.xAxis title: axis_style('得点')
      f.yAxis title: axis_style('最大ABCサイズ')

      f.series type: :line, name: '回帰直線', data: regression.regression_data, marker: { enabled: false }, color: 'black'
      f.series type: :scatter, name: '全員のコード', data: plots, color: '#2F7ED8'

      f.legend layout: :horizontal
    end.tap do |charts|
      yield charts if block_given?
    end
  end

  def strategies_count_charts(title, type, data, categories = nil)
    create_charts do |f|
      f.title text: title
      f.xAxis title: axis_style('提出日'), categories: categories, type: :datetime, labels: format_date
      f.yAxis title: axis_style('戦略数'), allowDecimals: false, min: 0
      f.series type: type, name: '戦略数', data: data.values, pointStart: data.keys.first, pointInterval: 1.days
    end
  end

  def format_date
    { format: '{value:%m.%d}' }
  end

  def format_score(text)
    "score : {point.x:.2f}<br />#{text} : {point.y:.2f}"
  end

  def axis_style(text)
    { text: text, style: { 'font-size' => '16px' } }
  end

  module_function :column_strategies_per_day, :line_strategies_total,
                  :scatter_abc_size,
                  :line_score, :bar_submits,
                  :axis_style
end

