class Theater < ApplicationRecord
  has_many :client_theater_ships, dependent: :destroy
  has_many :clients, through: :client_theater_ships
  has_many :time_tables
  belongs_to :city

  def self.question
    {
      attachment: {
        type: 'template',
        payload: {
          template_type: 'button',
          text: '需要指定電影院查詢嗎？',
          buttons: [
            { type: 'postback', title: '我想用電影院查', payload: 'ONE_THEATER' },
            { type: 'postback', title: '直接給我全部就好', payload: 'ALL_THEATER' }
          ]
        }
      }
    }
  end

  def self.taipei_regions
    self.where(city_id: [1, 22]).distinct.pluck(:region).compact
  end

  def self.regions
    { text: '請選擇區域', quick_replies: QuickReply.new(taipei_regions) }
  end
end
