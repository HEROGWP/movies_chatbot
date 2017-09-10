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
    if text.downcase == 'help' || text.downcase == '幫助'
      actions = ['推薦電影', '重設看電影的地區']
      message.reply(text: '你需要什麼幫忙嗎？', quick_replies: QuickReply.new(actions))
    elsif client.city.nil? || text.downcase == 'cities' || text.downcase == '重設看電影的地區'
      if City.pluck(:name).include?(text)
        city = City.find_by(name: text)
        client.city = city
        client.save

        movie_names = Movie.recommend
        message.reply(text: '你想看哪部電影？(如果選項沒有可以直接輸入)', quick_replies: QuickReply.new(movie_names))
      else
        client.update(city_id: nil)

        reply_text = <<~TEXT
          你想在哪個地區看電影？

          以下是目前支援的地區(如果選項沒有可以直接輸入):
          #{City.pluck(:name).join(', ')}
        TEXT

        # message.reply(text: reply_text)

        message.reply(text: reply_text, quick_replies: QuickReply.new(City.order(:priority).limit(11).pluck(:name)))
      end
    elsif text.downcase == 'movies' || text.downcase == '推薦電影' || text.downcase == '不知道'
      movie_names = Movie.recommend

      message.reply(text: '你想看哪部電影？', quick_replies: QuickReply.new(movie_names))
      # message.reply(text: movie_names.to_s)
    else
      movie = Movie.search(text, client)
      message.reply(text: movie[:name]) if movie[:name]

      movie[:data].each do |where|
        message.reply(text: where)
      end
    end
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    message.reply(text: '查無此電影!!!')
  end
end
