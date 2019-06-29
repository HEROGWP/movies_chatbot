class Theater < ApplicationRecord
  has_many :client_theater_ships, dependent: :destroy
  has_many :clients, through: :client_theater_ships
  has_many :time_tables
  belongs_to :city
end
