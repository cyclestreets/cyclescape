# frozen_string_literal: true

class Hashtag < ApplicationRecord
  # "[^"]+"|() the LHS matches all text inside quotes leaving the RHS to match the hashtag
  # Hashtag Regexp from https://github.com/ralovely/simple_hashtag/blob/4e8832a845258f1d1d55db404975cc6b49eb12fe/lib/simple_hashtag/hashtag.rb#L12
  # TODO: update Hashtag Regexp to use https://github.com/twitter/twitter-text/tree/master/rb
  HASHTAG_REGEX = /"[^"]+"|(?<space>\s|^|>)(?<hash_with_tag>#(?!(?:\w+?_|_\w+?)(?:\s|$))(?<tag_name>([[:alpha:]])[a-z1-9\-_]+))/i.freeze

  belongs_to :group
  has_many :hashtaggings
  has_many :messages, through: :hashtaggings

  validates :name, uniqueness: { scope: :group_id }

  scope :search, lambda { |term|
    return none unless term

    term = "%#{term.strip}%"
    where(arel_table[:name].matches(term))
  }

  def self.find_by_name(name)
    return nil unless name

    find_by(name: name.downcase)
  end

  def self.find_or_create_for_body(content, group)
    extract_tag_names(content).map do |tag_name|
      begin
        find_or_create_by(group: group, name: tag_name)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
  end

  def self.extract_tag_names(content)
    content.to_enum(:scan, HASHTAG_REGEX).map { Regexp.last_match[:tag_name]&.downcase }.compact.uniq
  end
end
