class City < ApplicationRecord
  has_many :theaters
  has_many :clients
end
