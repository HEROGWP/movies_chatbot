class Client < ApplicationRecord
  belongs_to :city, optional: true
  has_many :client_theater_ships, dependent: :destroy
  has_many :theaters, through: :client_theater_ships
end
