module ApplicationHelper
  WDAY = %w(日 月 火 水 木 金 土)

  def format_time(time)
    time.strftime("%Y.%m.%d(#{WDAY[time.wday]}) %H:%M")
  end
end

