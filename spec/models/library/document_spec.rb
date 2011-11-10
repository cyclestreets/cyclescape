# == Schema Information
#
# Table name: library_documents
#
#  id              :integer         not null, primary key
#  library_item_id :integer         not null
#  title           :string(255)     not null
#  file_uid        :string(255)
#  file_name       :string(255)
#  file_size       :integer
#

require 'spec_helper'

describe Library::Document do
  it_behaves_like "a library component"

  it "should be valid" do
    doc = FactoryGirl.create(:library_document)
    doc.should be_valid
  end

  context "link with library item" do
    let(:attrs) { FactoryGirl.attributes_for(:library_document) }

    it "should create a library item automatically" do
      doc = Library::Document.new(attrs)
      doc.save!.should be_true
      doc.item.should be_true
    end

    it "should create an item with reciprocal component links" do
      doc = Library::Document.new(attrs)
      doc.save!.should be_true
      doc.item.component_type.should == "Library::Document"
      doc.item.component_id.should == doc.id
      Library::Item.find(doc.library_item_id).component.should == doc
    end
  end
end
