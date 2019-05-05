# frozen_string_literal: true

# == Schema Information
#
# Table name: location_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LocationCategory < ApplicationRecord

  has_many :user_locations, foreign_key: 'category_id'

  validates :name, presence: true, uniqueness: true, length: { maximum: 60 }
end
