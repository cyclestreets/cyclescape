require 'spec_helper'

describe ThreadMailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:document) { FactoryGirl.create(:document_message, created_by: user) }

  describe 'new document messages' do
    it 'has a link to the new document' do
      subject = described_class.send(:new_document_message, document.message, user)
      expect(subject.body).to include("/threads/#{document.message.thread.id}/messages/#{document.message.id}/documents/#{document.id}")
    end
  end
end
