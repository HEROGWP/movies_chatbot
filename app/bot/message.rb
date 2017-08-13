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
  message.typing_on
  text = message.text
  begin
    if text.downcase == 'movies'
      movie_names = Movie.recommend

      message.reply(text: '你想看哪部電影？', quick_replies: QuickReply.new(movie_names))
      # message.reply(text: movie_names.to_s)
    else
      movie = Movie.search(text)
      message.reply(text: movie[:name]) if movie[:name]

      movie[:data].each do |where|
        message.reply(text: where)
      end
    end
  rescue => e
    message.reply(text: '查無此電影!!!')
  end
end
