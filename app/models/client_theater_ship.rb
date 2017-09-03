class ClientTheaterShip < ApplicationRecord
  belongs_to :client
  belongs_to :theater
end
