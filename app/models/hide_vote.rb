# frozen_string_literal: true


class HideVote < ApplicationRecord
  belongs_to :planning_application, counter_cache: true, touch: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :planning_application_id }
end

# == Schema Information
#
# Table name: hide_votes
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  planning_application_id :integer
#  user_id                 :integer
#
# Indexes
#
#  index_hide_votes_on_planning_application_id_and_user_id  (planning_application_id,user_id) UNIQUE
#
