class TimeTable < ApplicationRecord
  belongs_to :movie
  belongs_to :theater
end
