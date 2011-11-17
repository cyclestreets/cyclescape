# == Schema Information
#
# Table name: library_notes
#
#  id                  :integer         not null, primary key
#  library_item_id     :integer         not null
#  title               :string(255)
#  body                :text            not null
#  library_document_id :integer
#

require 'spec_helper'

describe Library::Note do
  it_behaves_like "a library component"

  it "should be valid" do
    note = FactoryGirl.create(:library_note)
    note.should be_valid
  end

  it { should belong_to(:document) }
  it { should validate_presence_of(:body) }
end
