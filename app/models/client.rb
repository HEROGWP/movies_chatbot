class Client < ApplicationRecord
  belongs_to :city, optional: true
  belongs_to :movie, optional: true
  has_many :client_theater_ships, dependent: :destroy
  has_many :theaters, through: :client_theater_ships

  def send_message(text)
    Bot.deliver({
      recipient: {
        id: uid,
      },
      message: {
        text: text,
      },
    }, access_token: ENV['ACCESS_TOKEN'])
  end
end
