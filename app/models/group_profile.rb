# == Schema Information
#
# Table name: group_profiles
#
#  id                   :integer          not null, primary key
#  group_id             :integer          not null
#  description          :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  location             :spatial          geometry, 4326
#  joining_instructions :text
#
# Indexes
#
#  index_group_profiles_on_group_id  (group_id)
#  index_group_profiles_on_location  (location)
#

class GroupProfile < ActiveRecord::Base
  include Locatable
  dragonfly_accessor :picture

  def picture_thumbnail
    picture.thumb('330x192#')
  end

  belongs_to :group
end
