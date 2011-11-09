# == Schema Information
#
# Table name: library_items
#
#  id             :integer         not null, primary key
#  component_id   :integer
#  component_type :string(255)
#  created_by_id  :integer         not null
#  created_at     :datetime        not null
#  updated_at     :datetime
#  deleted_at     :datetime
#  location       :spatial({:srid=
#

require 'spec_helper'

describe Library::Item do
  describe "associations" do
    it { should belong_to(:component) }
    it { should belong_to(:created_by) }
  end

  describe "validations" do
    it { should validate_presence_of(:created_by) }
  end
end
