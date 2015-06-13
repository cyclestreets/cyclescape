class LocationCategory < ActiveRecord::Base

  has_many :user_locations, foreign_key: 'category_id'

  validates :name, presence: true, uniqueness: true, length: { maximum: 60 }
end
