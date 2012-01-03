require "spec_helper"

MailProcessor = nil

describe MailboxReader do
  let(:config) do
    {host: "mail.example.com", user_name: "user@example.com", password: "secret",
      authentication: "PLAIN", mailbox: "INBOX", mail_processor: "MailProcessor"}
  end

  let(:imap) { double("IMAP connection") }

  describe "saving messages" do
    subject { MailboxReader.new(config) }
    let(:message) { File.read(raw_email_path) }

    describe "#save_message" do
      it "should create a saved record from the raw message" do
        record = double
        record.should_receive(:save!)
        InboundMail.should_receive(:new_from_message) do |arg|
          arg.should be_instance_of Mail::Message
          record
        end
        subject.save_message(message).should == record
      end
    end

    describe "#enqueue" do
      let(:record) { double(id: 31) }

      it "should use the configured mail processor" do
        Resque.should_receive(:enqueue).with(MailProcessor, anything)
        subject.enqueue(record)
      end

      it "should send the message ID" do
        Resque.should_receive(:enqueue).with(anything, 31)
        subject.enqueue(record)
      end
    end
  end
end
