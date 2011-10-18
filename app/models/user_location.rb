class UserLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :category, class_name: "LocationCategory"

  validates :location, presence: true
  validates :user, presence: true
  validates :category, presence: true
end
