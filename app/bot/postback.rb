
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

    postback.reply(City.setting_message)
  elsif City.pluck(:name).include?(postback.payload)
    city = City.find_by(name: postback.payload)
    client.update(city_id: city.id)

    postback.reply(Movie.recommend)
  elsif postback.payload == 'ONE_THEATER'
    postback.reply(Theater.regions)
  elsif postback.payload == 'ALL_THEATER'
    client.update(region: nil)
    postback.reply(client.movie.get_dates)
  elsif postback.payload == 'MOVIES'
    postback.reply(Movie.recommend)
  end
end
