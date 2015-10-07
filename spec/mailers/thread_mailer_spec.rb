require 'spec_helper'

describe ThreadMailer do
  let(:user) { create(:user) }
  let(:document) { create(:document_message, created_by: user) }

  describe 'new document messages' do
    it 'has a link to the new document' do
      subject = described_class.send(:new_document_message, document.message, user)
      expect(subject.body).to include("http://www.example.com#{document.message.component.file.url}")
    end
  end
end
