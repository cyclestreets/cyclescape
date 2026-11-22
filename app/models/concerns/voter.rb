# frozen_string_literal: true

# Something that votes on Voteable records (replaces the thumbs_up gem's acts_as_voter).
module Voter
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :voter, dependent: :destroy
  end

  def vote_for(voteable)
    vote(voteable, direction: :up)
  end

  def vote_against(voteable)
    vote(voteable, direction: :down)
  end

  def vote_exclusively_for(voteable)
    vote(voteable, direction: :up, exclusive: true)
  end

  def vote_exclusively_against(voteable)
    vote(voteable, direction: :down, exclusive: true)
  end

  def vote(voteable, direction:, exclusive: false)
    raise ArgumentError, "direction must be :up or :down" unless %i[up down].include?(direction)

    clear_votes(voteable) if exclusive
    Vote.create!(vote: direction == :up, voteable: voteable, voter: self)
  end

  def voted_for?(voteable)
    votes_on(voteable).exists?(vote: true)
  end

  def voted_against?(voteable)
    votes_on(voteable).exists?(vote: false)
  end

  def clear_votes(voteable)
    votes_on(voteable).destroy_all
  end

  private

  def votes_on(voteable)
    Vote.where(voter: self, voteable: voteable)
  end
end
