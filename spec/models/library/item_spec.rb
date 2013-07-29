# == Schema Information
#
# Table name: library_items
#
#  id             :integer          not null, primary key
#  component_id   :integer
#  component_type :string(255)
#  created_by_id  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime
#  deleted_at     :datetime
#  location       :spatial({:srid=>
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

  context "find by tags" do
    let!(:item) { FactoryGirl.create(:library_item, tags_string: "foo bar baz") }
    let!(:item2) { FactoryGirl.create(:library_item, tags_string: "bananas") }

    it "should return both notes" do
      thread = double(tags: [double(name: "foo"), double(name: "bananas")])
      items = Library::Item.find_by_tags_from(thread)
      items.should include(item)
      items.should include(item2)
      items.length.should eql(2)
    end

    it "shouldn't return the same item twice" do
      thread = double(tags: [double(name: "foo"), double(name: "bar")])
      items = Library::Item.find_by_tags_from(thread)
      items.should include(item)
      items.should_not include(item2)
      items.length.should eql(1)
    end
  end
end
