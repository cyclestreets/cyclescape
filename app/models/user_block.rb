class UserBlock < ApplicationRecord
  belongs_to :user
  belongs_to :blocked, class_name: "User"
end
