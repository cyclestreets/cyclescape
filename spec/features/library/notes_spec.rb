# frozen_string_literal: true

require "spec_helper"

describe "Library notes" do
  let(:note) { create(:library_note, :with_location) }

  context "as a public user" do
    before do
      visit library_note_path(note)
    end

    it "should show the note body correctly" do
      expect(page).to have_content(note.body)
      expect(page).to have_link(note.created_by.name)
      expect(page).not_to have_content(I18n.t("shared.tags.widget_content.edit_tags"))
    end
  end

  context "new", as: :site_user do
    it "should create a new note" do
      visit new_library_note_path
      fill_in "Note", with: "Note text goes here"
      click_on "Create Note"
      expect(page).to have_content("Note text goes here")
    end

    it "should auto link the text" do
      visit new_library_note_path
      fill_in "Note", with: "Text https://example.com more text"
      click_on "Create Note"
      expect(page).to have_link("https://example.com")
    end

    it "should create tags for the note" do
      visit new_library_note_path
      fill_in "Note", with: "blah blah blah"
      fill_in "Tags", with: "one two three"
      click_on "Create Note"
      expect(page).to have_content("three")
    end

    it "should have a cancel link back to the library page" do
      visit new_library_note_path
      click_on "Cancel"
      expect(page.current_path).to eq(library_path)
    end
  end

  context "with document" do
    let(:note) { create(:library_note_with_document) }

    before do
      visit library_note_path(note)
    end

    it "should show the document title" do
      expect(page).to have_content(note.document.title)
    end
  end

  context "tags" do
    include_context "signed in as a site user"

    before do
      visit library_note_path(note)
    end

    it "should be taggable", js: true do
      click_on "Edit tags"

      expect(page).not_to have_button("Edit tags")
      fill_in "resource_tags_string_tag", with: "cycle parking,"
      click_on I18n.t("shared.edit_tags.update")

      within(".widget-content.tags") do
        expect(page).to have_link("cycle-parking", href: "/tags/cycle-parking")
      end
    end
  end

  context "edit" do
    let(:edit_text) { I18n.t(".library.notes.show.edit") }
    context "as an admin" do
      include_context "signed in as admin"

      it "should show you a link" do
        visit library_note_path(note)
        expect(page).to have_selector("[data-bs-content*='#{edit_text}'] > .fa-cog")
      end

      it "should let you edit the note", js: true do
        visit library_note_path(note)

        page.find('.fa-cog').hover
        click_on edit_text

        expect(page).to have_content(I18n.t(".library.notes.edit.title"))
        fill_in "Note", with: "Something New and Very Useful"
        click_on "Save"
        expect(current_path).to eq(library_note_path(note))
        expect(page).to have_content("Something New and Very Useful")
      end
    end

    context "as the creator" do
      include_context "signed in as a site user"

      context "recent" do
        let(:note) { create(:library_note, created_by: current_user) }
        it "should show you a link" do
          visit library_note_path(note)
          expect(page).to have_selector("[data-bs-content*='#{edit_text}'] > .fa-cog")
        end
      end
    end

    context "as another user" do
      include_context "signed in as a site user"

      it "should not show you a link" do
        visit library_note_path(note)
        expect(page).not_to have_selector("[data-bs-content*='#{edit_text}'] > .fa-cog")
      end
    end
  end
end
