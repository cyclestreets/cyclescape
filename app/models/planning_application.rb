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
#  issue_id                :integer
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

class PlanningApplication < ActiveRecord::Base
  NOS_HIDE_VOTES = 2

  include Locatable

  belongs_to :issue
  has_many :hide_votes
  has_many :users, through: :hide_votes
  scope :not_hidden, -> { where('hide_votes_count < ?', NOS_HIDE_VOTES) }
  scope :ordered, -> { order('start_date DESC') }
  scope :relevant, -> { where(relevant: true) }

  validates :uid, :url, presence: true
  validates :uid, uniqueness: true
  before_save :set_relevant

  class << self
    def remove_old
      where('created_at < ?', 8.months.ago).where(issue_id: nil).delete_all
    end
  end

  def has_issue?
    issue_id
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
        #{description}\n\n
        #{address}\n\n
        #{url}\n\n#{authority_name}\n
        #{I18n.t("planning_application.issues.new.application_reference")} : #{uid}
      EOS
      issue.tags_string = "planning"
    end
  end

  protected

  def set_relevant
    self.relevant = relevant?
  end

  def relevant?
    return true unless authority_name == 'Cambridge'
    case uid
    when /\/(TTCA|COND.*|CLUED|ADV)$/
      false
    else
      true
    end
  end
end
