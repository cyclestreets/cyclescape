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

require 'spec_helper'

describe PlanningApplication do
  pending "add some examples to (or delete) #{__FILE__}"
end
