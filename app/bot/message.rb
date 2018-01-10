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
    # elsif City.pluck(:name).include?(text)
    #   city = City.find_by(name: text)
    #   client.city = city
    #   client.save

    #   movie_names = Movie.recommend
    #   message.reply(text: '你想看哪部電影？(如果選項沒有可以直接輸入)', quick_replies: QuickReply.new(movie_names))
    # elsif ['movies', '不知道'].include?(text.downcase)
    #   movie_names = Movie.recommend

    #   message.reply(text: '你想看哪部電影？', quick_replies: QuickReply.new(movie_names))
    #   # message.reply(text: movie_names.to_s)
    else
      movie = Movie.where('name like ?', "%#{text}%").order(id: :desc).first
      if movie
        message.reply(text: movie.name)
        timestables = movie.times[client.city.name]
        if timestables&.present?
          while timestables.present?
            message.reply(text: timestables.shift(3).join("\n"))
          end
        else
          message.reply(text: "目前沒有可觀看的時間!!!")
        end
      else
        message.reply(text: '查無此電影!!!')
      end
    end
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    message.reply(text: '查無此電影!!!')
  end
end
