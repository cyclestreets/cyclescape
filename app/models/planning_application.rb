# frozen_string_literal: true

# == Schema Information
#
# Table name: planning_applications
#
#  id                      :integer          not null, primary key
#  address                 :text
#  postcode                :string(255)
#  description             :text
#  openlylocal_council_url :string(255)
#  url                     :text
#  uid                     :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  location                :spatial          geometry, 4326
#  authority_name          :string(255)
#  start_date              :date
#  hide_votes_count        :integer          default(0)
#
# Indexes
#
#  index_planning_applications_on_issue_id  (issue_id)
#  index_planning_applications_on_uid       (uid) UNIQUE
#

class PlanningApplication < ApplicationRecord
  NOS_HIDE_VOTES = 2.freeze

  include Locatable

  has_one :issue
  has_many :hide_votes
  has_many :users, through: :hide_votes
  scope :not_hidden, -> { where(arel_table[:hide_votes_count].lt(NOS_HIDE_VOTES)) }
  scope :ordered, -> { order(start_date: :desc) }
  scope :relevant, -> { where(relevant: true) }
  scope :for_local_authority, ->(la) { where(arel_table[:authority_param].matches(la.parameterize)) }
  scope :search, ->(term) do
    return none unless term
    term = "%#{term.strip}%"
    where(arel_table[:uid].matches(term).or(arel_table[:description].matches(term)))
  end

  validates :uid, :url, :authority_name, :authority_param, presence: true
  validates :uid, uniqueness: { scope: :authority_param }
  before_save :set_relevant
  before_validation :set_authority_param, on: :create

  class << self
    def remove_old
      transaction do
        includes(:issue)
          .where(issues: { planning_application_id: nil })
          .where("#{quoted_table_name}.created_at < ?", 8.months.ago)
          .find_each(&:destroy)
      end
    end
  end

  def has_issue?
    issue
  end

  def title
    if description.try(:present?)
      [uid, description].join(" ")
    else
      [uid, authority_name].join(" ")
    end
  end

  def part_hidden?
    hide_votes_count > 0 && hide_votes_count < NOS_HIDE_VOTES
  end

  def fully_hidden?
    hide_votes_count >= NOS_HIDE_VOTES
  end

  def populate_issue
    build_issue.tap do |issue|
      issue.title = "#{I18n.t("planning_application.issues.new.title_prefix")} : #{title}"
      issue.location = location
      issue.external_url = url
      issue.description = <<-EOS
<p>#{description}</p>
<p>#{address}</p>
<p>#{authority_name}</p>
#{I18n.t("planning_application.issues.new.application_reference")} : <a href=#{url}>#{uid}</a>
      EOS
      issue.tags_string = "planning"
    end
  end

  def calculate_relevant(loaded_planning_filters = nil)
    planning_filters = loaded_planning_filters || PlanningFilter.all
    planning_filters.none? { |filter| filter.matches?(self) }
  end

  private

  def set_relevant
    self.relevant = calculate_relevant
    true
  end

  def set_authority_param
    self.authority_param = authority_name.try(:parameterize)
  end
end
