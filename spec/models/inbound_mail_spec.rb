require 'spec_helper'

describe InboundMail do
  describe "validations" do
    it { should validate_presence_of(:recipient) }
    it { should validate_presence_of(:raw_message) }
  end

  context "new_from_message" do
    let(:raw_email) { File.read(raw_email_path) }
    let(:mail) { Mail.new(raw_email) }

    it "should create a new object from a Mail message" do
      test = InboundMail.new_from_message(mail)
      test.should be_a(InboundMail)
      test.recipient.should == mail.to.first
      test.raw_message.should == mail.to_s
    end
  end

  context "message" do
    let(:mail) { Factory.create(:inbound_mail) }

    it "should return a Mail::Message object" do
      mail.message.should be_a(Mail::Message)
    end
  end
end
