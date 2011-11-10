require 'spec_helper'

describe Library::Note do
  it_behaves_like "a library component"

  it "should be valid" do
    note = FactoryGirl.create(:library_note)
    note.should be_valid
  end
end
