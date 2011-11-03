# == Schema Information
#
# Table name: user_locations
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  category_id :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  location    :spatial({:srid=
#

class UserLocation < ActiveRecord::Base
  include Locatable

  belongs_to :user
  belongs_to :category, class_name: "LocationCategory"

  validates :location, presence: true
  validates :user, presence: true
  validates :category, presence: true

  def overlapping_groups
    GroupProfile.where("st_intersects(location, ?)", self.location).order("st_area(location) asc").map{ |p| p.group}
  end
end
