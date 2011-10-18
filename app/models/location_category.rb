class LocationCategory < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true, length: { maximum: 60 }
end
