require "spec_helper"

describe "Library documents" do
  let(:document) { FactoryGirl.create(:library_document) }

  context "as a public user" do
    it "should show me the document page" do
      visit library_document_path(document)
      page.should have_content(document.title)
      page.should have_link("Download")
    end

    it "should download the document" do
      visit library_document_path(document)
      click_on "Download"
      page.response_headers["Content-Type"].should == document.file.mime_type
      page.response_headers["Content-Disposition"].should include("filename=\"#{document.file_name}\"")
    end
  end

  context "new", as: :site_user do
    it "should create a new document" do
      visit new_library_document_path
      attach_file "Document", pdf_document_path
      fill_in "Title", with: "Case studies"
      click_on "Upload"
      current_path.should == library_document_path(Library::Document.last)
      page.should have_content("Case studies")
      page.should have_link("Download")
    end

    it "should have a cancel link back to the library page" do
      visit new_library_document_path
      click_on "Cancel"
      page.current_path.should == library_path
    end

    it "should update the document"
  end

  context "adding notes", as: :site_user do
    def add_note
      visit library_document_path(document)
      fill_in "Note", with: "Here's a note about this document."
      click_on "Attach note"
    end

    it "should add a new note to the document" do
      add_note
      page.should have_content(document.title)
      page.should have_content("Notes")
      page.should have_content("Here's a note about this document.")
    end

    it "should return me back to the document" do
      add_note
      current_path.should == library_document_path(document)
    end
  end
end
