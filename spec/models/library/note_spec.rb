# frozen_string_literal: true


require "spec_helper"

describe Library::Note do
  it_behaves_like "a library component"

  it "should be valid" do
    note = create(:library_note)
    expect(note).to be_valid
  end

  it { is_expected.to belong_to(:document) }
  it { is_expected.to validate_presence_of(:body) }

  describe "searchable text" do
    let(:note) { create(:library_note) }

    it "should have a searchable title" do
      expect(note.searchable_text).to include(note.title)
    end

    it "should have a searchable body" do
      expect(note.searchable_text).to include(note.body)
    end
  end
end
