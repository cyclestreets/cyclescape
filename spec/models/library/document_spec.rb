require 'spec_helper'

describe Library::Document do
  it { should belong_to(:item) }

  it "should be valid" do
    doc = FactoryGirl.create(:library_document)
    doc.should be_valid
  end
end
