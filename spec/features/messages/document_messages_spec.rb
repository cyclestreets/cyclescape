require 'spec_helper'

describe 'Document messages' do
  let(:thread) { FactoryGirl.create(:message_thread) }

  def document_form
    within('#new-document-message') { yield }
  end

  context 'new' do
    include_context 'signed in as a site user'

    before do
      visit thread_path(thread)
    end

    it 'should post a document message' do
      document_form do
        attach_file('File', pdf_document_path)
        fill_in 'Title', with: 'An important document'
        click_on 'Add Attachment'
      end

      expect(page).to have_content('Attachment added')
      expect(page).to have_content('An important document')
      expect(page).to have_link('Download Attachment')
    end
  end

  context 'show' do
    let(:message) { FactoryGirl.create(:message, thread: thread) }
    let!(:document_message) { FactoryGirl.create(:document_message, message: message, created_by: FactoryGirl.create(:user)) }

    before do
      visit thread_path(thread)
    end

    it 'should show the title and have a link' do
      expect(page).to have_content(document_message.title)
      expect(page).to have_link('Download Attachment')
    end

    it 'should download the document' do
      click_on 'Download'
      expect(page.response_headers['Content-Type']).to eq(document_message.file.mime_type)
      expect(page.response_headers['Content-Disposition']).to include("filename=\"#{document_message.file_name}\"")
    end
  end
end
