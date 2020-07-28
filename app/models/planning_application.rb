# frozen_string_literal: true

class PlanningApplication < ApplicationRecord
  NOS_HIDE_VOTES = 2
  APP_SIZES = %w[Large Medium Small].freeze
  APP_STATES = {
    "Undecided" => "The application is currently active, no decision has been made",
    "Permitted" => "The application was approved",
    "Conditions" => "The application was approved, but conditions were imposed",
    "Rejected" => "The application was refused",
    "Withdrawn" => "The application was withdrawn before a decision was taken",
    "Referred" => "The application was referred to government or to another authority",
    "Unresolved" => "The application is no longer active but no decision was made eg split decision",
    "Other" => "Status not known"
  }.freeze

  APP_TYPES = {
    "Full" => "=> Full and householder planning applications",
    "Outline" => "Proposals prior to a full application, including assessments, scoping opinions, outline applications etc",
    "Amendment" => "Amendments or alterations arising from existing or previous applications",
    "Conditions" => "Discharge of conditions imposed on existing applications",
    "Heritage" => "Conservation issues and listed buildings",
    "Trees" => "Tree and hedge works",
    "Advertising" => "Advertising and signs",
    "Telecoms" => "Telecommunications including phone masts",
    "Other" => "All other types eg agricultural, electrical",
  }.freeze

  include Locatable

  has_one :issue
  has_many :hide_votes
  has_many :users, through: :hide_votes
  scope :not_hidden, -> { where(arel_table[:hide_votes_count].lt(NOS_HIDE_VOTES)) }
  scope :ordered, -> { order(start_date: :desc) }
  scope :relevant, -> { where(relevant: true) }
  scope :for_local_authority, ->(la) { where(arel_table[:authority_param].matches(la.parameterize)) }
  scope :search, lambda { |term|
    return none unless term

    term = "%#{term.strip}%"
    where(arel_table[:uid].matches(term).or(arel_table[:description].matches(term)))
  }

  validates :uid, :url, :authority_name, :authority_param, presence: true
  validates :uid, uniqueness: { scope: :authority_param }
  validates :app_size, inclusion: { in: APP_SIZES, allow_nil: true }
  validates :app_state, inclusion: { in: APP_STATES.keys, allow_nil: true }
  validates :app_type, inclusion: { in: APP_TYPES.keys, allow_nil: true }

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
      issue.title = "#{I18n.t('planning_application.issues.new.title_prefix')} : #{title}"
      issue.location = location
      issue.external_url = url
      issue.description = <<~EOS
        <p>#{description}</p>
        <p>#{address}</p>
        <p>#{authority_name}</p>
        #{I18n.t('planning_application.issues.new.application_reference')} : <a href=#{url}>#{uid}</a>
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

# == Schema Information
#
# Table name: planning_applications
#
#  id               :integer          not null, primary key
#  address          :text
#  app_size         :string
#  app_state        :string
#  app_type         :string
#  authority_name   :string(255)
#  authority_param  :string
#  description      :text
#  hide_votes_count :integer          default(0)
#  location         :geometry({:srid= geometry, 4326
#  postcode         :string(255)
#  relevant         :boolean          default(TRUE), not null
#  start_date       :date
#  uid              :string(255)      not null
#  url              :text
#  when_updated     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  associated_id    :string
#
# Indexes
#
#  index_planning_applications_on_associated_id            (associated_id)
#  index_planning_applications_on_location                 (location) USING gist
#  index_planning_applications_on_uid_and_authority_param  (uid,authority_param) UNIQUE
#
