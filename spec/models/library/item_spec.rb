# frozen_string_literal: true

require "spec_helper"

describe Library::Item do
  it_should_behave_like "a taggable model"

  describe "associations" do
    it { is_expected.to belong_to(:component) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:created_by) }
  end

  context "find by tags" do
    let!(:item) { create(:library_item, tags_string: "foo,bar,baz") }
    let!(:item2) { create(:library_item, tags_string: "bananas") }

    it "should return both notes" do
      thread = double(tags: [double(name: "foo"), double(name: "bananas")])
      items = Library::Item.find_by_tags_from(thread)
      expect(items).to include(item)
      expect(items).to include(item2)
      expect(items.length).to eql(2)
    end

    it "shouldn't return the same item twice" do
      thread = double(tags: [double(name: "foo"), double(name: "bar")])
      items = Library::Item.find_by_tags_from(thread)
      expect(items).to include(item)
      expect(items).not_to include(item2)
      expect(items.length).to eql(1)
    end
  end
end
