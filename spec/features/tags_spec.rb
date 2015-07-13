require 'spec_helper'

describe 'Tags' do
  let(:tag) { create(:tag) }
  let!(:thread) { create(:message_thread, tags: [tag]) }
  let!(:issue) { create(:issue, tags: [tag]) }
  let!(:library_note) { create(:library_note) }
  let!(:bogus_tag) { build(:tag, name: 'unfindable') }

  it 'should show results' do
    library_note.item.tags = [tag]
    visit tag_path(tag)
    expect(page).to have_content(I18n.t('.tags.show.heading', name: tag.name))
    expect(page).to have_link(thread.title)
    expect(page).to have_link(issue.title)
    expect(page).to have_link(library_note.title)
  end

  it 'should show an empty results page for a ficticious tag' do
    visit tag_path(bogus_tag)
    expect(page).to have_content(I18n.t('.tags.show.heading', name: bogus_tag.name))
    expect(page).to have_content(I18n.t('.tags.show.unrecognised', name: bogus_tag.name))
  end
end

describe 'autocomplete_tags' do
  context 'autocomplete_tag_name' do
    let(:tag) { create(:tag) }

    it 'should return a tag from a full name tag search' do
      visit autocomplete_tags_path(term: tag.name)
      expect(page).to have_content("\"label\":\"#{tag.name}\"")
    end

    it 'should return a tag from a partial search start' do
      visit autocomplete_tags_path(term: tag.name[0, 2])
      expect(page).to have_content("\"label\":\"#{tag.name}\"")
    end

    it 'should return a tag from a partial search end' do
      visit autocomplete_tags_path(term: tag.name[-2, 2])
      expect(page).to have_content("\"label\":\"#{tag.name}\"")
    end

    it 'should return a tag from a partial search middle' do
      visit autocomplete_tags_path(term: tag.name[-4, 2])
      expect(page).to have_content("\"label\":\"#{tag.name}\"")
    end
  end
end
