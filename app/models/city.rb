class City < ApplicationRecord
  has_many :theaters
  has_many :clients

  def self.setting_message
    reply_text = <<~TEXT
      你想在哪個地區看電影？
      以下是目前支援的地區(如果選項沒有可以直接輸入):
      #{self.pluck(:name).join(', ')}
    TEXT

    { text: reply_text, quick_replies: QuickReply.new(self.order(:priority).limit(11).pluck(:name)) }
  end
end
