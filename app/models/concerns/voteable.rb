# frozen_string_literal: true

# Something users can vote up or down (replaces the thumbs_up gem's acts_as_voteable).
module Voteable
  extend ActiveSupport::Concern

  PLUSMINUS_SQL = "SUM(CASE votes.vote WHEN true THEN 1 WHEN false THEN -1 ELSE 0 END)"

  included do
    has_many :votes, as: :voteable, dependent: :destroy
  end

  class_methods do
    # All records (including those without votes) ordered by net score,
    # with the score available on each record as #plusminus_tally.
    def plusminus_tally
      joins(sanitize_sql_array([<<~SQL.squish, polymorphic_name]))
        LEFT OUTER JOIN votes ON votes.voteable_id = #{quoted_table_name}.id AND votes.voteable_type = ?
      SQL
        .group(:id)
        .select(arel_table[Arel.star], Arel.sql("#{PLUSMINUS_SQL} AS plusminus_tally"), Arel.sql("COUNT(votes.id) AS vote_count"))
        .order(Arel.sql("plusminus_tally DESC"))
    end
  end

  def votes_for
    votes.where(vote: true).count
  end

  def votes_against
    votes.where(vote: false).count
  end

  def votes_count
    votes.size
  end

  def voters_who_voted
    votes.includes(:voter).map(&:voter).uniq
  end

  def plusminus
    has_attribute?(:plusminus_tally) ? plusminus_tally : votes_for - votes_against
  end
end
