class IssueCategory < ActiveRecord::Base
  has_many :issues, foreign_key: "category_id"

  validates :name, presence: true, uniqueness: true, length: { maximum: 60 }
end
