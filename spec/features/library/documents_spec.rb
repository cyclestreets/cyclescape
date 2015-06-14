require 'spec_helper'

describe 'Library documents' do
  let(:document) { FactoryGirl.create(:library_document) }

  context 'as a public user' do
    before do
      visit library_document_path(document)
    end

    it 'should show me the document page' do
      expect(page).to have_content(document.title)
      expect(page).to have_link('Download')
    end

    it 'should download the document' do
      click_on 'Download'
      expect(page.response_headers['Content-Type']).to eq(document.file.mime_type)
      expect(page.response_headers['Content-Disposition']).to include("filename=\"#{document.file_name}\"")
    end

    it 'should not show a link to edit tags' do
      expect(page).not_to have_content(I18n.t('.shared.tags.panel.edit_tags'))
    end
  end

  context 'new', as: :site_user do
    it 'should create a new document' do
      visit new_library_document_path
      attach_file 'Document', pdf_document_path
      fill_in 'Title', with: 'Case studies'
      click_on 'Upload'
      expect(current_path).to eq(library_document_path(Library::Document.last))
      expect(page).to have_content('Case studies')
      expect(page).to have_link('Download')
    end

    it 'should have a cancel link back to the library page' do
      visit new_library_document_path
      click_on 'Cancel'
      expect(page.current_path).to eq(library_path)
    end

    it "should tell the user when they don't fill in the fields" do
      visit new_library_document_path
      click_on 'Upload'
      expect(page).to have_content("can't be blank")
    end

    it 'should create tags for the document' do
      visit new_library_document_path
      attach_file 'Document', pdf_document_path
      fill_in 'Title', with: 'Case studies'
      fill_in 'Tags', with: 'one two three'
      click_on 'Upload'
      expect(page).to have_content('three')
    end

    it 'should update the document'
  end

  context 'adding notes', as: :site_user do
    def add_note
      visit library_document_path(document)
      fill_in 'Note', with: "Here's a note about this document."
      click_on 'Attach note'
    end

    it 'should add a new note to the document' do
      add_note
      expect(page).to have_content(document.title)
      expect(page).to have_content('Notes')
      expect(page).to have_content("Here's a note about this document.")
    end

    it 'should return me back to the document' do
      add_note
      expect(current_path).to eq(library_document_path(document))
    end
  end

  context 'tags' do
    include_context 'signed in as a site user'

    before do
      visit library_document_path(document)
    end

    it 'should be taggable' do
      click_on 'Edit tags'
      fill_in 'Tags', with: 'cycle parking'
      click_on I18n.t('.formtastic.actions.library/item.update_tags')
      expect(JSON.parse(page.source)['tagspanel']).to have_content('parking')
    end
  end
end
