require "spec_helper"

describe "Library item messages" do
  let(:thread) { FactoryGirl.create(:message_thread) }
  let(:document) { FactoryGirl.create(:library_document) }
  let(:note) { FactoryGirl.create(:library_note) }
  let(:documents) { FactoryGirl.create_list(:library_document, 3) }
  let!(:notes) { FactoryGirl.create_list(:library_note, 3) }

  context "new", as: :site_user do
    before do
      visit thread_path(thread)
    end

    pending "should post a library item message" do
      library_item_form do
        select notes.first.title, from: "Item"
        fill_in "Message", with: "This note seems relevant."
        click_on "Add Library Item"
      end
      page.should have_link(notes.first.title)
      page.should have_content("This note seems relevant")
    end
  end

  context "document" do
    it "should have a link to the document"
  end

  context "note" do
    it "should have a link to the note"
    it "should show the content of the note"

    context "with document" do
      include_context "signed in as a site user"
      let!(:note) { FactoryGirl.create(:library_note_with_document) }

      before do
        visit thread_path(thread)
      end

      pending "should show a referenced document" do
        page.should have_content("Attached to document")
        page.should have_link(note.document.title)
      end
    end
  end
end
