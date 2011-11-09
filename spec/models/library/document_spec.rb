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
  it { should belong_to(:item) }

  it "should be valid" do
    doc = FactoryGirl.create(:library_document)
    doc.should be_valid
  end
end
