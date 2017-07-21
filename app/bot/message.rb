include Facebook::Messenger

Bot.on :message do |message|
  # TODO: Make bot replay something
  message.reply(text: 'Hello, human!')
end
