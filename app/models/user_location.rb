# == Schema Information
#
# Table name: user_locations
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  category_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location    :spatial          geometry, 4326
#
# Indexes
#
#  index_user_locations_on_location  (location)
#  index_user_locations_on_user_id   (user_id)
#

class UserLocation < ActiveRecord::Base
  include Locatable

  belongs_to :user
  belongs_to :category, class_name: 'LocationCategory'

  validates :location, presence: true
  validates :user, presence: true
  validates :category, presence: true

  def overlapping_groups
    GroupProfile.where('st_intersects(location, ?)', location).order('st_area(location) asc').map { |p| p.group }
  end

  def buffered
    location.buffer(Geo::USER_LOCATIONS_BUFFER).union(location)
  end
end
