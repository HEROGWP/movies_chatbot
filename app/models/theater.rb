class Theater < ApplicationRecord
  has_many :client_theater_ships, dependent: :destroy
  has_many :clients, through: :client_theater_ships
end
