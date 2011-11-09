require "spec_helper"

describe "Library documents" do
  context "as a public user" do
    let(:document) { FactoryGirl.create(:library_document) }

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

  context "as a site user", as: :site_user do
    it "should create a new document" do
      visit new_library_document_path
      attach_file "Document", pdf_document_path
      fill_in "Title", with: "Case studies"
      click_on "Upload"
      puts Library::Document.all.inspect
      current_path.should == library_document_path(Library::Document.last)
      page.should have_content("Case studies")
      page.should have_link("Download")
    end

    it "should update the document"
  end
end
