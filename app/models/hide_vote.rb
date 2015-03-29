class HideVote < ActiveRecord::Base
  belongs_to :planning_application, counter_cache: true
  belongs_to :user

  attr_accessible :user_id, :planning_application_id

  validates :user_id, uniqueness: { scope: :planning_application_id }
end
