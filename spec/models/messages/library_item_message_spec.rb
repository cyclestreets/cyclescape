require "spec_helper"

describe LibraryItemMessage do
  it "should be valid" do
    message = FactoryGirl.create(:library_item_message_with_document)
    message.should be_valid
  end
end
