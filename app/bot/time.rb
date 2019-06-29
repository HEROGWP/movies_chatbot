module MyTime
    WEEKDAY = {
    '1' => '一',
    '2' => '二',
    '3' => '三',
    '4' => '四',
    '5' => '五',
    '6' => '六',
    '7' => '日',
  }

  def weekday
    WEEKDAY[strftime('%u')]
  end

  def date_weekday
    strftime("%F(#{weekday})")
  end
end

class ActiveSupport::TimeWithZone
  include MyTime
end

class Time
  include MyTime
end
