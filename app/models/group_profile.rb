# frozen_string_literal: true

class GroupProfile < ApplicationRecord
  MAX_LOCAL_AREA = 10

  dragonfly_accessor :picture
  dragonfly_accessor :logo

  include Locatable
  include Base64ToDragonfly

  scope :with_location,   -> { where.not(location: nil) }
  scope :ordered,         -> { order(created_at: :desc) }
  scope :local,           -> { where("ST_AREA(location) < ?", MAX_LOCAL_AREA) }
  scope :ordered_by_size, -> { order(Arel.sql("ST_AREA(location) DESC")) }
  scope :enabled,         -> { joins(:group).merge(Group.enabled) }

  validates :new_user_email, presence: true

  def picture_thumbnail
    picture.thumb("330x192#")
  end

  def logo_thumbnail
    logo.thumb("330x>")
  end

  belongs_to :group, inverse_of: :profile
end

# == Schema Information
#
# Table name: group_profiles
#
#  id                   :integer          not null, primary key
#  description          :text
#  joining_instructions :text
#  location             :geometry({:srid= geometry, 4326
#  logo_uid             :string
#  new_user_email       :text             not null
#  picture_name         :string(255)
#  picture_uid          :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  group_id             :integer          not null
#
# Indexes
#
#  index_group_profiles_on_group_id  (group_id)
#  index_group_profiles_on_location  (location) USING gist
#
