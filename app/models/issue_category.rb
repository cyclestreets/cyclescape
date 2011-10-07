# == Schema Information
#
# Table name: issue_categories
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class IssueCategory < ActiveRecord::Base
  has_many :issues, foreign_key: "category_id"

  validates :name, presence: true, uniqueness: true, length: { maximum: 60 }
end
