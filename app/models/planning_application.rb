# == Schema Information
#
# Table name: planning_applications
#
#  id                      :integer         not null, primary key
#  openlylocal_id          :integer         not null
#  openlylocal_url         :string(255)
#  address                 :string(255)
#  postcode                :string(255)
#  description             :text
#  council_name            :string(255)
#  openlylocal_council_url :string(255)
#  url                     :string(255)
#  uid                     :string(255)     not null
#  issue_id                :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  location                :spatial({:srid=
#

class PlanningApplication < ActiveRecord::Base
  attr_accessible :hidden
  NOS_HIDE_VOTES = 2

  include Locatable

  belongs_to :issue
  has_many :hide_votes
  has_many :users, through: :hide_votes
  scope :not_hidden, where('hide_votes_count < ?', NOS_HIDE_VOTES)
  scope :ordered, order('start_date DESC')

  validates :uid, :url, :location, presence: true
  validates :uid, uniqueness: true

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
end
