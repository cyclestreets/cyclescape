# frozen_string_literal: true

class Hashtag < ActiveRecord::Base
  HASHTAG_REGEX = /(?<space>\s|^)(?<hash_with_tag>#(?!(?:\w+?_|_\w+?)(?:\s|$))(?<tag_name>([[:alpha:]])[a-z1-9\-_]+))/i

  belongs_to :group
  has_many :hashtaggings
  has_many :messages, through: :hashtaggings

  validates :name, uniqueness: { scope: :group_id }

  scope :search, ->(term) do
    return none unless term
    term = "%#{term.strip}%"
    where(arel_table[:name].matches(term))
  end

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
    content.to_enum(:scan, HASHTAG_REGEX).map { Regexp.last_match[:tag_name].downcase }.uniq
  end
end
