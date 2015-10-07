require 'spec_helper'

describe ThreadMailer do
  let(:user) { create(:user) }
  let(:document) { create(:document_message, created_by: user) }

  describe 'new document messages' do
    it 'has correct text in email' do
      subject = described_class.send(:new_document_message, document.message, user)
      expect(subject.body).to include("http://www.example.com#{document.file.url}")
      expect(subject.body).to include(I18n.t('.thread_mailer.new_document_message.view_the_document'))
      expect(subject.to).to include(user.email)
    end
  end
end
