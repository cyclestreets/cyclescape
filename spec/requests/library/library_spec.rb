require "spec_helper"

describe "Library" do
  context "as a public user" do
    let!(:documents) { FactoryGirl.create_list(:library_document, 5) }
    let!(:notes) { FactoryGirl.create_list(:library_note, 5) }

    before do
      visit library_path
    end

    it "should have links to 5 recent documents" do
      documents.each do |doc|
        page.should have_link(doc.title)
      end
    end

    it "should have links to 5 recent notes" do
      notes.each do |note|
        page.should have_link(note.title)
      end
    end

    context "search" do
      let(:search_field) { I18n.t("libraries.show.search") }
      let(:search_button) { I18n.t("libraries.show.search_submit") }

      before do
        visit library_path
      end

      it "should find the first note" do
        fill_in search_field, with: notes[0].title
        click_on search_button

        page.should have_content("Search Results")
        page.should_not have_content("No results")
        page.should have_content(notes[0].title)
      end

      it "should find the first document" do
        fill_in search_field, with: documents[0].title
        click_on search_button

        page.should have_content("Search Results")
        page.should_not have_content("No results")
        page.should have_content(documents[0].title)
      end

      context "clear button" do
        it "should go to the library front page" do
          fill_in search_field, with: "test"
          click_on search_button
          page.should have_content("Results")
          click_on "Clear"
          page.current_path.should == library_path
        end
      end
    end
  end
end
