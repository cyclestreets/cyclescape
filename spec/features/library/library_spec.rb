require 'spec_helper'

describe 'Library' do
  context 'as a public user' do
    let!(:documents) { FactoryGirl.create_list(:library_document, 5) }
    let!(:notes) { FactoryGirl.create_list(:library_note, 5) }

    before do
      visit library_path
    end

    it 'should have links to 5 recent documents' do
      documents.each do |doc|
        expect(page).to have_link(doc.title)
      end
    end

    it 'should have links to 5 recent notes' do
      notes.each do |note|
        expect(page).to have_link(note.title)
      end
    end

    context 'search' do
      let(:search_field) { 'query' }
      let(:search_button) { I18n.t('layouts.search.search_button') }

      before do
        visit library_path
      end

      it 'should find the first note' do
        within('.main-search-box') do
          fill_in search_field, with: notes[0].title
          click_on search_button
        end

        expect(page).to have_content('Search Results')
        expect(page).not_to have_content('No results')
        expect(page).to have_content(notes[0].title)
      end

      it 'should find the first document' do
        within('.main-search-box') do
          fill_in search_field, with: documents[0].title
          click_on search_button
        end

        expect(page).to have_content('Search Results')
        expect(page).not_to have_content('No results')
        expect(page).to have_content(documents[0].title)
      end
    end
  end
end
