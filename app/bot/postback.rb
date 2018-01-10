
include Facebook::Messenger

Bot.on :postback do |postback|
  # postback.sender    # => { 'id' => '1008372609250235' }
  # postback.recipient # => { 'id' => '2015573629214912' }
  # postback.sent_at   # => 2016-04-22 21:30:36 +0200
  # postback.payload   # => 'EXTERMINATE'

  client = Client.find_or_create_by(uid: postback.sender['id'])
  # postback.reply(text: postback.payload)
  if ['GET_STARTED_PAYLOAD'].include?(postback.payload)
    client.update(city_id: nil)

    reply_text = <<~TEXT
      你想在哪個地區看電影？
      以下是目前支援的地區(如果選項沒有可以直接輸入):
      #{City.pluck(:name).join(', ')}
    TEXT

    postback.reply(text: reply_text, quick_replies: QuickReply.new(City.order(:priority).limit(11).pluck(:name)))
  elsif City.pluck(:name).include?(postback.payload)
    city = City.find_by(name: postback.payload)
    client.city = city
    client.save

    movie_names = Movie.recommend
    postback.reply(text: '你想看哪部電影？(如果選項沒有可以直接輸入)', quick_replies: QuickReply.new(movie_names))
  elsif postback.payload == 'MOVIES'
    movie_names = Movie.recommend

    postback.reply(text: '你想看哪部電影？', quick_replies: QuickReply.new(movie_names))
  end
end
