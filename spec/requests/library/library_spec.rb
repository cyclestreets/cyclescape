require "spec_helper"

describe "Library" do
  context "as a public user" do
    let!(:documents) { FactoryGirl.create_list(:library_document, 5) }
    let!(:notes) { FactoryGirl.create_list(:library_note, 5) }

    before do
      visit library_path
    end

    it "should have a search box" do
      page.should have_field("Search")
    end

    it "should have links to 5 recent documents" do
      documents.each do |doc|
        page.should have_link(doc.title)
      end
    end

    it "should have links to 5 recent notes" do
      notes.each do |note|
        page.should have_link(note.body.truncate(60))
      end
    end
  end
end
