# == Schema Information
#
# Table name: votes
#
#  id            :integer          not null, primary key
#  vote          :boolean          default(FALSE)
#  voteable_id   :integer          not null
#  voteable_type :string(255)      not null
#  voter_id      :integer
#  voter_type    :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  fk_one_vote_per_user_per_entity               (voter_id,voter_type,voteable_id,voteable_type) UNIQUE
#  index_votes_on_voteable_id_and_voteable_type  (voteable_id,voteable_type)
#  index_votes_on_voter_id_and_voter_type        (voter_id,voter_type)
#

class Vote < ActiveRecord::Base
  scope :descending, -> { order(created_at: :desc) }

  belongs_to :voteable, polymorphic: true
  belongs_to :voter, polymorphic: true

  # Comment out the line below to allow multiple votes per user.
  validates_uniqueness_of :voteable_id, scope: [:voteable_type, :voter_type, :voter_id]
end
