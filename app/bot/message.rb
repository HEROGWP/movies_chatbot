include Facebook::Messenger

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
  text = message.text
  begin
    if text == "movies"
      movie_names = []
      doc = Nokogiri::HTML(open("https://tw.movies.yahoo.com/movie_intheaters.html?page=#{rand(1..8)}"))
      movies = doc.css('.release_movie_name')
      movies.each do |movie|
        movie_names << movie.css('a').first.text.split(' ').first
      end

      message.reply(text: '你想看哪部電影？', quick_replies: QuickReply.new(movie_names))
      # message.reply(text: movie_names.to_s)
    elsif text == 'Hi'
      message.reply(text: 'Hello')
    else
      doc = Nokogiri::HTML(open(URI.encode("https://tw.movies.yahoo.com/moviesearch_result.html?keyword=#{text[0..100]}&type=movie&page=1")))
      m = doc.css('a').select{|m| m.text == '時刻表' }
      m = m.select{|m| m.attributes['href'] != nil }
      if !m.first.nil?
        movie_name = doc.css('.release_movie_name').first.css('a').first.text
        message.reply(text: movie_name)
        url = m.first.attributes['href'].value
        doc = Nokogiri::HTML(open(url))

        times = doc.css('.area_time._c').first(20).compact.map do |where|
          times = where.css('.time .select').map do |time|
            time.text
          end.join(', ')
          message.reply(text: where.css('.adds').first.css('a').text + "(#{where.css('.tapR').text})" + "\n" + times) if times.present?
          times == '' ? nil : times
        end

        message.reply(text: "目前沒有可觀看的時間!!!") if times.compact.blank?

      else
        message.reply(text: "查無此電影!!!")
      end
    end
  rescue => e
    message.reply(text: "查無此電影!!!")
  end

end

