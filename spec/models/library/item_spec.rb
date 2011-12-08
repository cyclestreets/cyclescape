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
  it_should_behave_like "a taggable model"

  describe "associations" do
    it { should belong_to(:component) }
    it { should belong_to(:created_by) }
  end

  describe "validations" do
    it { should validate_presence_of(:created_by) }
  end

  context "find with index" do
    let!(:note) { FactoryGirl.create(:library_note) }

    it "should be returned in a search query" do
      results = Library::Item.find_with_index(note.title)
      results.should include(note.item)
    end
  end
end
