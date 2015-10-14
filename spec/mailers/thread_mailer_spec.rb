require 'spec_helper'

describe ThreadMailer do
  let(:user)          { create(:user) }
  let(:message_one)   { create(:message, created_by: user) }
  let(:message_two)   { create(:message, created_by: user, in_reply_to: message_one, thread: thread) }
  let(:message_three) { create(:message, created_by: user, in_reply_to: message_two, thread: thread) }
  let(:thread)        { message_one.thread }
  let!(:document)     { create(:document_message, created_by: user, message: message_three, thread: thread) }

  describe 'new document messages' do
    it 'has correct text in email' do
      subject = described_class.send(:new_document_message, message_three, user)
      expect(subject.body).to include("http://www.example.com#{document.file.url}")
      expect(subject.body).to include(I18n.t('.thread_mailer.new_document_message.view_the_document'))
      expect(subject.to).to include(user.email)
      expect(subject.header['References'].value).to eq(
        "<message-#{message_one.public_token}@cyclescape.org> <message-#{message_two.public_token}@cyclescape.org>")
    end
  end
end
