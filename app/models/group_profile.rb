# frozen_string_literal: true

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
  MAX_LOCAL_AREA = 10

  include Locatable
  dragonfly_accessor :picture
  dragonfly_accessor :logo

  scope :with_location,   -> { where.not(location: nil) }
  scope :ordered,         -> { order(created_at: :desc) }
  scope :local,           -> { where("ST_AREA(location) < ?", MAX_LOCAL_AREA) }
  scope :ordered_by_size, -> { order("ST_AREA(location) DESC")}
  scope :enabled,         -> { joins(:group).merge(Group.enabled) }
  validates :new_user_email, presence: true

  def picture_thumbnail
    picture.thumb('330x192#')
  end

  def logo_thumbnail
    logo.thumb('330x>')
  end

  belongs_to :group, inverse_of: :profile
end
