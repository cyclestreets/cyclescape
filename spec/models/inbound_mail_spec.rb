require 'spec_helper'

describe InboundMail do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:recipient) }
    it { is_expected.to validate_presence_of(:raw_message) }
  end

  context 'new_from_message' do
    let(:raw_email) { File.read(raw_email_path) }
    let(:mail) { Mail.new(raw_email) }

    it 'should create a new object from a Mail message' do
      test = InboundMail.new_from_message(mail)
      expect(test).to be_a(InboundMail)
      expect(test.recipient).to eq(mail.to.first)
      expect(test.raw_message).to eq(mail.to_s)
    end

    context 'with email in cc' do
      let(:raw_email) { File.read(raw_email_path('cc')) }
      let(:mail) { Mail.new(raw_email) }

      it 'should create a new object from a Mail message' do
        test = InboundMail.new_from_message(mail)
        expect(test).to be_a(InboundMail)
        expect(test.recipient).to eq(mail.cc.first)
        expect(test.raw_message).to eq(mail.to_s)
      end
    end
  end

  context 'message' do
    let(:mail) { create(:inbound_mail) }

    it 'should return a Mail::Message object' do
      expect(mail.message).to be_a(Mail::Message)
    end
  end

  context 'factory' do
    it 'should have a known recipient' do
      mail = build(:inbound_mail)
      expect(mail.recipient).to eq('cyclescape@example.com')
      expect(mail.message.to.first).to eq('cyclescape@example.com')
    end

    it 'should adjust the recipients' do
      mail = build(:inbound_mail, to: 'quagmire@giggity.com')
      expect(mail.recipient).to eq('quagmire@giggity.com')
      expect(mail.message.to.first).to eq('quagmire@giggity.com')
    end
  end
end
