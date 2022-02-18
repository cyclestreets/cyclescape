# frozen_string_literal: true

class UserLocation < ApplicationRecord
  include Locatable

  belongs_to :user
  belongs_to :category, class_name: "LocationCategory"

  validates :location, presence: true
  validates :user, presence: true, uniqueness: true
  after_create :approve_user

  def buffered
    buffered_loc = location.buffer(Geo::USER_LOCATIONS_BUFFER)
    union_self = buffered_loc.union(location)
    if union_self && !union_self.try(:empty?)
      union_self
    else
      buffered_loc
    end
  end

  private

  def approve_user
    user.approve!
  end
end

# == Schema Information
#
# Table name: user_locations
#
#  id          :integer          not null, primary key
#  location    :geometry({:srid= geometry, 4326
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#  user_id     :integer          not null
#
# Indexes
#
#  index_user_locations_on_category_id  (category_id)
#  index_user_locations_on_location     (location) USING gist
#  index_user_locations_on_user_id      (user_id) UNIQUE
#
