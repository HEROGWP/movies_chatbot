include Facebook::Messenger

# Bot.on :message do |message|
#   # TODO: Make bot replay something
#   message.reply(text: 'Hello, human!')
# end

# Bot.on :message do |message|
#   # TODO: Make bot replay something
#   text = message.text
#   client = Client.find_or_create_by(uid: message.sender['id'])

#   if text.end_with?('?')
#     keyword = Suggest.order('length(text) DESC').find_by("? LIKE '%' || text || '%'", text[0..-2])

#     if keyword
#       message.reply(text: 'What do you want?', quick_replies: QuickReply.new(keyword.options))
#     else
#       message.reply(text: 'what?')
#     end
#   else

#     # keyword = Keyword.where("? LIKE '%' || text || '%'", text).order('length(text) DESC').limit(5).sample
#     keyword = Keyword.where(group: client.context || '')
#                     .where("? LIKE '%' || text || '%'", text)
#                     .order('length(text) DESC').limit(5).sample

#     if keyword
#       client.update_attributes(context: keyword.context)
#       message.reply(text: keyword.reply)
#     else
#       message.reply(text: 'what?')
#     end
#   end


# end

Bot.on :message do |message|
  # TODO: Make bot replay something
  client = Client.find_or_create_by(uid: message.sender['id'])
  message.typing_on
  text = message.text
  begin
    if text.downcase == 'hi'
      message.reply(text: 'Hello')
    # elsif ['help', '幫助'].include?(text.downcase)
    #   question = '你需要什麼幫忙嗎？'
    #   buttons = ['推薦電影', '重設看電影的地區']
    #   message.reply(attachment: Button.data(question, buttons))
    elsif City.pluck(:name).include?(text)
      city = City.find_by(name: text)
      client.update(city_id: city.id)

      message.reply(Movie.recommend)
    # elsif ['movies', '不知道'].include?(text.downcase)
    #   movie_names = Movie.recommend

    #   message.reply(text: '你想看哪部電影？', quick_replies: QuickReply.new(movie_names))
    #   # message.reply(text: movie_names.to_s)
    elsif client.city.nil?
      message.reply(City.setting_message)
    elsif text.match(/\A(\d{4}-\d{2}-\d{2})\(.\)/i)
      time_current = Time.parse($1)
      city_ids = [client.city_id]
      city_ids << 22 if city_ids == [1] # 台北市 台北二輪
      city_ids << 5 if city_ids == [4] # 桃園 中壢

      group_time_tables = TimeTable.joins(:theater)
                                   .where(movie_id: client.movie.id, theaters: { city_id: city_ids })
                                   .where(start_time: time_current..time_current.end_of_day)
                                   .pluck_all(:'theaters.name', :theater_type, :start_time)
                                   .group_by{ |time_table| time_table['name'] }


      time_tables = group_time_tables.map do |theater_name, time_tables|
                      times = time_tables.map do |time_table|
                                "#{time_table['start_time'].strftime('%R')}(#{time_table['theater_type']})"
                              end.join(', ')

                      "#{theater_name}\n#{times}"
                    end

      message.reply(text: time_current.date_weekday)
      if time_tables.blank?
        message.reply(text: '目前沒有可觀看的時間!!!')
        message.reply(Movie.recommend)
        next
      end

      while time_tables.present?
        message.reply(text: time_tables.shift(3).join("\n"))
      end

      message.reply(Movie.recommend)
    else
      movie = Movie.where('name like ?', "%#{text}%").order(id: :desc).first
      next message.reply(text: '查無此電影!!!') if !movie
      message.reply(attachment: movie.website('查看更多'))
      client.update(movie_id: movie.id)
      message.reply(Movie.get_dates(movie.name))
    end
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    message.reply(text: '系統繁忙中，請稍候再次查詢')
  end
end
