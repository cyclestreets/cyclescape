# == Schema Information
#
# Table name: hide_votes
#
#  id                      :integer          not null, primary key
#  planning_application_id :integer
#  user_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_hide_votes_on_planning_application_id_and_user_id  (planning_application_id,user_id) UNIQUE
#

class HideVote < ActiveRecord::Base
  belongs_to :planning_application, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :planning_application_id }
end
