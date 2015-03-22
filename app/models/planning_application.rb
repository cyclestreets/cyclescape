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
  include Locatable

  belongs_to :issue

  validates :uid, :url, :location, presence: true
  validates :uid, uniqueness: true

  def has_issue?
    issue_id
  end

  def title
    if !description.empty?
      [uid, description].join(" ")
    else
      [uid, authority_name].join(" ")
    end
  end
end
